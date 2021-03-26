# (c) 2012-2014, Michael DeHaan <michael.dehaan@gmail.com>
# (c) 2017 Ansible Project
#
# (c) 2021 Modified by vjrj for LA Community
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = '''
    callback: default
    short_description: default Ansible screen output but to file (colorized)
    version_added: historical
    description:
        - This is the default output callback for ansible-playbook modified for the LA community to log colorized, souce: https://github.com/ansible/ansible/blob/stable-2.10/lib/ansible/plugins/callback/default.py
    extends_documentation_fragment:
      - default_callback
    options:
      log_folder:
        version_added: '2.9'
        default: /home/ubuntu/ansible/logs
        description: The folder where log files will be created.
        env:
          - name: ANSIBLE_LOG_FOLDER
        ini:
          - section: defaults
            key: log_folder
      log_file:
        version_added: '2.9'
        default: results.json
        description: The folder where log files will be created.
        env:
          - name: ANSIBLE_LOG_FILE
        ini:
          - section: defaults
            key: log_file
'''

import os

from ansible.utils.path import makedirs_safe
from ansible import constants as C
from ansible import context
from ansible.playbook.task_include import TaskInclude
from ansible.plugins.callback import CallbackBase
from ansible.utils.color import colorize, hostcolor, stringc
from ansible.module_utils._text import to_bytes


# These values use ansible.constants for historical reasons, mostly to allow
# unmodified derivative plugins to work. However, newer options added to the
# plugin are not also added to ansible.constants, so authors of derivative
# callback plugins will eventually need to add a reference to the common docs
# fragment for the 'default' callback plugin

# these are used to provide backwards compat with old plugins that subclass from default
# but still don't use the new config system and/or fail to document the options
# TODO: Change the default of check_mode_markers to True in a future release (2.13)
COMPAT_OPTIONS = (('display_skipped_hosts', C.DISPLAY_SKIPPED_HOSTS),
                  ('display_ok_hosts', True),
                  ('show_custom_stats', C.SHOW_CUSTOM_STATS),
                  ('display_failed_stderr', False),
                  ('check_mode_markers', False),
                  ('show_per_host_start', False))


class CallbackModule(CallbackBase):

    '''
    This is the default callback interface, which simply prints messages
    to stdout when new callback events are received.
    '''

    CALLBACK_VERSION = 2.0
    # CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'colorized-to-file'

    def __init__(self):

        self._play = None
        self._last_task_banner = None
        self._last_task_name = None
        self._task_type_cache = {}
        super(CallbackModule, self).__init__()

    def set_options(self, task_keys=None, var_options=None, direct=None):

        super(CallbackModule, self).set_options(task_keys=task_keys, var_options=var_options, direct=direct)

        self.log_folder = self.get_option("log_folder")
        self.log_file = self.get_option("log_file")

        if not os.path.exists(self.log_folder):
            makedirs_safe(self.log_folder)
        self.fpath = os.path.join(self.log_folder, self.log_file)

        # for backwards compat with plugins subclassing default, fallback to constants
        for option, constant in COMPAT_OPTIONS:
            try:
                value = self.get_option(option)
            except (AttributeError, KeyError):
                self._display.deprecated("'%s' is subclassing DefaultCallback without the corresponding doc_fragment." % self._load_name,
                                         version='2.14', collection_name='ansible.builtin')
                value = constant
            setattr(self, option, value)

    def log(self, data):
        msg = to_bytes('%s\n' %data)

        with open(self.fpath, "ab") as fd:
            fd.write(msg)

    # Adapted from: https://github.com/ansible/ansible/blob/stable-2.10/lib/ansible/utils/display.py
    def log_banner(self, data):
        msg = data
        msg = msg.strip()
        star_len = 95 - len(msg)
        if star_len <= 3:
            star_len = 3
        stars = u"*" * star_len
        self.log(u"\n%s %s" % (msg, stars))

    def v2_runner_on_failed(self, result, ignore_errors=False):

        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        self._clean_results(result._result, result._task.action)

        if self._last_task_banner != result._task._uuid:
            self._print_task_banner(result._task)

        self._handle_exception(result._result, use_stderr=self.display_failed_stderr)
        self._handle_warnings(result._result)

        if result._task.loop and 'results' in result._result:
            self._process_items(result)

        else:
            if delegated_vars:
                self.log(stringc("fatal: [%s -> %s]: FAILED! => %s" % (result._host.get_name(), delegated_vars['ansible_host'],
                                                                            self._dump_results(result._result)),
                                      color=C.COLOR_ERROR))
            else:
                self.log(stringc("fatal: [%s]: FAILED! => %s" % (result._host.get_name(), self._dump_results(result._result)),
                                      color=C.COLOR_ERROR))

        if ignore_errors:
            self.log(stringc("...ignoring", color=C.COLOR_SKIP))

    def v2_runner_on_ok(self, result):

        delegated_vars = result._result.get('_ansible_delegated_vars', None)

        if isinstance(result._task, TaskInclude):
            return
        elif result._result.get('changed', False):
            if self._last_task_banner != result._task._uuid:
                self._print_task_banner(result._task)

            if delegated_vars:
                msg = "changed: [%s -> %s]" % (result._host.get_name(), delegated_vars['ansible_host'])
            else:
                msg = "changed: [%s]" % result._host.get_name()
            color = C.COLOR_CHANGED
        else:
            if not self.display_ok_hosts:
                return

            if self._last_task_banner != result._task._uuid:
                self._print_task_banner(result._task)

            if delegated_vars:
                msg = "ok: [%s -> %s]" % (result._host.get_name(), delegated_vars['ansible_host'])
            else:
                msg = "ok: [%s]" % result._host.get_name()
            color = C.COLOR_OK

        self._handle_warnings(result._result)

        if result._task.loop and 'results' in result._result:
            self._process_items(result)
        else:
            self._clean_results(result._result, result._task.action)

            if self._run_is_verbose(result):
                msg += " => %s" % (self._dump_results(result._result),)
            self.log(stringc(msg, color=color))

    def v2_runner_on_skipped(self, result):

        if self.display_skipped_hosts:

            self._clean_results(result._result, result._task.action)

            if self._last_task_banner != result._task._uuid:
                self._print_task_banner(result._task)

            if result._task.loop and 'results' in result._result:
                self._process_items(result)
            else:
                msg = "skipping: [%s]" % result._host.get_name()
                if self._run_is_verbose(result):
                    msg += " => %s" % self._dump_results(result._result)
                self.log(stringc(msg, color=C.COLOR_SKIP))

    def v2_runner_on_unreachable(self, result):
        if self._last_task_banner != result._task._uuid:
            self._print_task_banner(result._task)

        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if delegated_vars:
            msg = "fatal: [%s -> %s]: UNREACHABLE! => %s" % (result._host.get_name(), delegated_vars['ansible_host'], self._dump_results(result._result))
        else:
            msg = "fatal: [%s]: UNREACHABLE! => %s" % (result._host.get_name(), self._dump_results(result._result))
        self.log(stringc(msg, color=C.COLOR_UNREACHABLE))

    def v2_playbook_on_no_hosts_matched(self):
        self.log(stringc("skipping: no hosts matched", color=C.COLOR_SKIP))

    def v2_playbook_on_no_hosts_remaining(self):
        self.log_banner("NO MORE HOSTS LEFT")

    def v2_playbook_on_task_start(self, task, is_conditional):
        self._task_start(task, prefix='TASK')

    def _task_start(self, task, prefix=None):
        # Cache output prefix for task if provided
        # This is needed to properly display 'RUNNING HANDLER' and similar
        # when hiding skipped/ok task results
        if prefix is not None:
            self._task_type_cache[task._uuid] = prefix

        # Preserve task name, as all vars may not be available for templating
        # when we need it later
        if self._play.strategy in ('free', 'host_pinned'):
            # Explicitly set to None for strategy free/host_pinned to account for any cached
            # task title from a previous non-free play
            self._last_task_name = None
        else:
            self._last_task_name = task.get_name().strip()

            # Display the task banner immediately if we're not doing any filtering based on task result
            if self.display_skipped_hosts and self.display_ok_hosts:
                self._print_task_banner(task)

    def _print_task_banner(self, task):
        # args can be specified as no_log in several places: in the task or in
        # the argument spec.  We can check whether the task is no_log but the
        # argument spec can't be because that is only run on the target
        # machine and we haven't run it thereyet at this time.
        #
        # So we give people a config option to affect display of the args so
        # that they can secure this if they feel that their stdout is insecure
        # (shoulder surfing, logging stdout straight to a file, etc).
        args = ''
        if not task.no_log and C.DISPLAY_ARGS_TO_STDOUT:
            args = u', '.join(u'%s=%s' % a for a in task.args.items())
            args = u' %s' % args

        prefix = self._task_type_cache.get(task._uuid, 'TASK')

        # Use cached task name
        task_name = self._last_task_name
        if task_name is None:
            task_name = task.get_name().strip()

        if task.check_mode and self.check_mode_markers:
            checkmsg = " [CHECK MODE]"
        else:
            checkmsg = ""
        self.log_banner(u"%s [%s%s]%s" % (prefix, task_name, args, checkmsg))
        if self._display.verbosity >= 2:
            path = task.get_path()
            if path:
                self.log(stringc(u"task path: %s" % path, color=C.COLOR_DEBUG))

        self._last_task_banner = task._uuid

    def v2_playbook_on_cleanup_task_start(self, task):
        self._task_start(task, prefix='CLEANUP TASK')

    def v2_playbook_on_handler_task_start(self, task):
        self._task_start(task, prefix='RUNNING HANDLER')

    def v2_runner_on_start(self, host, task):
        if self.get_option('show_per_host_start'):
            self.log(stringc(" [started %s on %s]" % (task, host), color=C.COLOR_OK))

    def v2_playbook_on_play_start(self, play):
        name = play.get_name().strip()
        if play.check_mode and self.check_mode_markers:
            checkmsg = " [CHECK MODE]"
        else:
            checkmsg = ""
        if not name:
            msg = u"PLAY%s" % checkmsg
        else:
            msg = u"PLAY [%s]%s" % (name, checkmsg)

        self._play = play

        self.log_banner(msg)

    def v2_on_file_diff(self, result):
        if result._task.loop and 'results' in result._result:
            for res in result._result['results']:
                if 'diff' in res and res['diff'] and res.get('changed', False):
                    diff = self._get_diff(res['diff'])
                    if diff:
                        if self._last_task_banner != result._task._uuid:
                            self._print_task_banner(result._task)
                        self.log(diff)
        elif 'diff' in result._result and result._result['diff'] and result._result.get('changed', False):
            diff = self._get_diff(result._result['diff'])
            if diff:
                if self._last_task_banner != result._task._uuid:
                    self._print_task_banner(result._task)
                self.log(diff)

    def v2_runner_item_on_ok(self, result):

        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        if isinstance(result._task, TaskInclude):
            return
        elif result._result.get('changed', False):
            if self._last_task_banner != result._task._uuid:
                self._print_task_banner(result._task)

            msg = 'changed'
            color = C.COLOR_CHANGED
        else:
            if not self.display_ok_hosts:
                return

            if self._last_task_banner != result._task._uuid:
                self._print_task_banner(result._task)

            msg = 'ok'
            color = C.COLOR_OK

        if delegated_vars:
            msg += ": [%s -> %s]" % (result._host.get_name(), delegated_vars['ansible_host'])
        else:
            msg += ": [%s]" % result._host.get_name()

        msg += " => (item=%s)" % (self._get_item_label(result._result),)

        self._clean_results(result._result, result._task.action)
        if self._run_is_verbose(result):
            msg += " => %s" % self._dump_results(result._result)
        self.log(stringc(msg, color=color))

    def v2_runner_item_on_failed(self, result):
        if self._last_task_banner != result._task._uuid:
            self._print_task_banner(result._task)

        delegated_vars = result._result.get('_ansible_delegated_vars', None)
        self._clean_results(result._result, result._task.action)
        self._handle_exception(result._result)

        msg = "failed: "
        if delegated_vars:
            msg += "[%s -> %s]" % (result._host.get_name(), delegated_vars['ansible_host'])
        else:
            msg += "[%s]" % (result._host.get_name())

        self._handle_warnings(result._result)
        self.log(stringc(msg + " (item=%s) => %s" % (self._get_item_label(result._result), self._dump_results(result._result)), color=C.COLOR_ERROR))

    def v2_runner_item_on_skipped(self, result):
        if self.display_skipped_hosts:
            if self._last_task_banner != result._task._uuid:
                self._print_task_banner(result._task)

            self._clean_results(result._result, result._task.action)
            msg = "skipping: [%s] => (item=%s) " % (result._host.get_name(), self._get_item_label(result._result))
            if self._run_is_verbose(result):
                msg += " => %s" % self._dump_results(result._result)
            self.log(stringc(msg, color=C.COLOR_SKIP))

    def v2_playbook_on_include(self, included_file):
        msg = 'included: %s for %s' % (included_file._filename, ", ".join([h.name for h in included_file._hosts]))
        label = self._get_item_label(included_file._vars)
        if label:
            msg += " => (item=%s)" % label
        self.log(stringc(msg, color=C.COLOR_SKIP))

    def v2_playbook_on_stats(self, stats):
        self.log_banner("PLAY RECAP")

        hosts = sorted(stats.processed.keys())
        for h in hosts:
            t = stats.summarize(h)

            self.log(
                u"%s : %s %s %s %s %s %s %s" % (
                    hostcolor(h, t),
                    colorize(u'ok', t['ok'], C.COLOR_OK),
                    colorize(u'changed', t['changed'], C.COLOR_CHANGED),
                    colorize(u'unreachable', t['unreachable'], C.COLOR_UNREACHABLE),
                    colorize(u'failed', t['failures'], C.COLOR_ERROR),
                    colorize(u'skipped', t['skipped'], C.COLOR_SKIP),
                    colorize(u'rescued', t['rescued'], C.COLOR_OK),
                    colorize(u'ignored', t['ignored'], C.COLOR_WARN),
                )
            )

        self.log("")

        # print custom stats if required
        if stats.custom and self.show_custom_stats:
            self.log_banner("CUSTOM STATS: ")
            # per host
            # TODO: come up with 'pretty format'
            for k in sorted(stats.custom.keys()):
                if k == '_run':
                    continue
                self.log('\t%s: %s' % (k, self._dump_results(stats.custom[k], indent=1).replace('\n', '')))

            # print per run custom stats
            if '_run' in stats.custom:
                self.log("")
                self.log('\tRUN: %s' % self._dump_results(stats.custom['_run'], indent=1).replace('\n', ''))
            self.log("")

        if context.CLIARGS['check'] and self.check_mode_markers:
            self.log_banner("DRY RUN")

    def v2_playbook_on_start(self, playbook):
        if self._display.verbosity > 1:
            from os.path import basename
            self.log_banner("PLAYBOOK: %s" % basename(playbook._file_name))

        # show CLI arguments
        if self._display.verbosity > 3:
            if context.CLIARGS.get('args'):
                self.log(stringc('Positional arguments: %s' % ' '.join(context.CLIARGS['args']),
                                      color=C.COLOR_VERBOSE))

            for argument in (a for a in context.CLIARGS if a != 'args'):
                val = context.CLIARGS[argument]
                if val:
                    self.log(stringc('%s: %s' % (argument, val), color=C.COLOR_VERBOSE))

        if context.CLIARGS['check'] and self.check_mode_markers:
            self.log_banner("DRY RUN")

    def v2_runner_retry(self, result):
        task_name = result.task_name or result._task
        msg = "FAILED - RETRYING: %s (%d retries left)." % (task_name, result._result['retries'] - result._result['attempts'])
        if self._run_is_verbose(result, verbosity=2):
            msg += "Result was: %s" % self._dump_results(result._result)
        self.log(stringc(msg, color=C.COLOR_DEBUG))

    def v2_playbook_on_notify(self, handler, host):
        if self._display.verbosity > 1:
            self.log(stringc("NOTIFIED HANDLER %s for %s" % (handler.get_name(), host), color=C.COLOR_VERBOSE))
