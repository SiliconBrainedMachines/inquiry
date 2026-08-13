import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import 'commands/doctor.dart';
import 'commands/init.dart';
import 'commands/tui.dart';
import 'commands/uninstall.dart';
import 'commands/upgrade.dart';
import 'commands/version.dart';
import '../../hosts/deployer.dart';

/// `help` is not registered here: `modular_cli_sdk` renders it from the command
/// catalog these registrations feed, so a command cannot ship without appearing
/// in it. Inquiry's own hand-written help had already drifted — the
/// `specification` and `issue` modules were absent from it for two releases.
void buildGlobalModule(
  ModuleBuilder m, {
  required HostDeployer cleaner,
  Assets? assets,
}) {
  m.query<TuiInput, TuiOutput>(
    '',
    (req) => TuiCommand(TuiInput.fromCliRequest(req)),
    description: 'Display Inquiry status and FSM diagram',
    params: TuiInput.params,
  );

  m.query<InitInput, InitOutput>(
    'init',
    (req) => InitCommand(InitInput.fromCliRequest(req)),
    description:
        'Set up the Inquiry workspace in this repo (cleanrooms + .inquiry). Install a host first with `iq host get`.',
    params: InitInput.params,
  );

  m.query<VersionInput, VersionOutput>(
    'version',
    (req) => VersionCommand(VersionInput.fromCliRequest(req)),
    description: 'Print the current CLI version',
    params: VersionInput.params,
  );

  m.query<DoctorInput, DoctorOutput>(
    'doctor',
    (req) => DoctorCommand(DoctorInput.fromCliRequest(req), assets: assets),
    description: 'Verify prerequisites (inquiry, git, gh, gh auth, gh copilot)',
    params: DoctorInput.params,
  );

  m.command<UpgradeInput, UpgradeOutput>(
    'upgrade',
    (req) => UpgradeCommand(UpgradeInput.fromCliRequest(req)),
    description: 'Download and install the latest Inquiry release',
    params: UpgradeInput.params,
  );

  m.command<UninstallInput, UninstallOutput>(
    'uninstall',
    (req) => UninstallCommand(
      UninstallInput.fromCliRequest(req),
      deployer: cleaner,
    ),
    description: 'Remove Inquiry CLI from the system',
    params: UninstallInput.params,
  );
}
