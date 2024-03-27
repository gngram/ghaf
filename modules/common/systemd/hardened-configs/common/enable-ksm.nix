{

  ###########
  ## Paths ##
  ###########
  #ExecStartPost = "tbsh_client 127.0.0.1 80";
  #ExecSearchPath=
  /*
   * Colon separated list of absolute paths to search for executeables. ExecSearchPath= overrides
   * $PATH if $PATH is not supplied by the user through Environment=, EnvironmentFile= or PassEnvironment=.
   *
   *https://www.freedesktop.org/software/systemd/man/systemd.exec.html#WorkingDirectory=
   */

  #WorkingDirectory=
  /*
   * Sets the working directory for executed processes. If set to "~", the home directory of the user
   * specified in User= is used. If not set, defaults to the root directory when systemd is running as
   * a system instance and the respective user's home directory if run as user.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#WorkingDirectory=
   */

  #RootDirectory=
  /*
   * Sets the root directory for executed processes, with the chroot(2) system call. If this is used, it
   * must be ensured that the process binary and all its auxiliary files are available in the chroot() jail.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootDirectory=
   */

  #RootImage=
  /*
   * A path to a block device node or regular file as argument. This call is similar to RootDirectory= however
   * mounts a file system hierarchy from a block device node or loopback file instead of a directory. The device
   * node or file system image file needs to contain a file system without a partition table, or a file system
   * within an MBR/MS-DOS or GPT partition table with only a single Linux-compatible partition, or a set of file
   * systems within a GPT partition table that follows the Discoverable Partitions Specification.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootImage=
   */

  #RootImageOptions=
  /*
   * A comma-separated list of mount options that will be used on disk images specified by RootImage=. Optionally
   * a partition name can be prefixed, followed by colon, in case the image has multiple partitions, otherwise
   * partition name "root" is implied. Options for multiple partitions can be specified in a single line with space
   * separators. Assigning an empty string removes previous assignments. Duplicated options are ignored.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootImageOptions=
   */

  #RootEphemeral=
  /*
   * Options: true/false
   * Default: false
   * If enabled, executed processes will run in an ephemeral copy of the root directory or root image. The ephemeral
   * copy is placed in /var/lib/systemd/ephemeral-trees/ while the service is active and is cleaned up when the service
   * is stopped or restarted.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootEphemeral=
   */

  #RootHash=
  /*
   * Root hash specified in hexadecimal, or the path to a file containing a root hash in ASCII hexadecimal format.
   * This option enables data integrity checks using dm-verity, if the used image contains the appropriate integrity
   * data or if RootVerity= is used. The specified hash must match the root hash of integrity data.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootHash=
   */

  #RootHashSignature=
  /*
   * A PKCS7 signature of the RootHash= option as a path to a DER-encoded signature file, or as an ASCII base64 string
   * encoding of a DER-encoded signature prefixed by "base64:". The dm-verity volume will only be opened if the signature
   * of the root hash is valid and signed by a public key present in the kernel keyring. If this option is not specified,
   * but a file with the .roothash.p7s suffix is found next to the image file, bearing otherwise the same name
   * the signature is read from it and automatically used.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootHashSignature=
   */

  #RootVerity=
  /*
   * Path to a data integrity (dm-verity) file. This option enables data integrity checks using dm-verity, if RootImage=
   * is used and a root-hash is passed and if the used image itself does not contain the integrity data. The integrity data
   * must be matched by the root hash.
   * This option is supported only for disk images that contain a single file system, without an enveloping partition table.
   * Images that contain a GPT partition table should instead include both root file system and matching Verity data in
   * the same image, implementing the Discoverable Partitions Specification.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootVerity=
   */

  #RootImagePolicy=, MountImagePolicy=, ExtensionImagePolicy=
  /*
   * Image policy string as per systemd.image-policy to use when mounting the disk images (DDI) specified in RootImage=,
   * MountImage=, ExtensionImage=, respectively. If not specified the following policy string is the default for
   * RootImagePolicy= and MountImagePolicy:
   * root=verity+signed+encrypted+unprotected+absent: \
        usr=verity+signed+encrypted+unprotected+absent: \
        home=encrypted+unprotected+absent: \
        srv=encrypted+unprotected+absent: \
        tmp=encrypted+unprotected+absent: \
        var=encrypted+unprotected+absent
   * The default policy for ExtensionImagePolicy= is:
   * root=verity+signed+encrypted+unprotected+absent: \
        usr=verity+signed+encrypted+unprotected+absent
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RootImagePolicy=
   */

  #MountAPIVFS=
  /*
   * Boolean, If true, a private mount namespace for the unit's processes is created and the API file systems
   * /proc/, /sys/, /dev/ and /run/ (as an empty "tmpfs") are mounted inside of it, unless they are already mounted.
   * Note that this option has no effect unless used in conjunction with RootDirectory=/RootImage=.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#MountAPIVFS=
   */

  #ProtectProc=
  /*
   * Options: "noaccess", "invisible", "ptraceable" or "default" (which it defaults to).
   * This controls the "hidepid=" mount option of the "procfs" instance for the unit that controls which directories
   * with process metainformation (/proc/PID) are visible and accessible: when set to "noaccess" the ability to
   * access most of other users' process metadata in /proc/ is taken away for processes of the service. When set to
   * "invisible" processes owned by other users are hidden from /proc/. If "ptraceable" all processes that cannot
   * be ptrace()'ed by a process are hidden to it. If "default" no restrictions on /proc/ access or visibility are made.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectProc=
   */

  #ProcSubset=
  /*
   * Options: "all" (the default), "pid"
   * If "pid", all files and directories not directly associated with process management and introspection are made
   * invisible in the /proc/ file system configured for the unit's processes. This controls the "subset=" mount option
   * of the "procfs" instance for the unit.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProcSubset=
   */

  #BindPaths=, BindReadOnlyPaths=
  /*
   * Whitespace separated list of bind mount definitions.
   * Configures unit-specific bind mounts. A bind mount makes a particular file or directory available at an additional
   * place in the unit's view of the file system. Any bind mounts created with this option are specific to the unit,
   * and are not visible in the host's mount table. Each definition consists of a colon-separated triple of source path,
   * destination path and option string, where the latter two are optional. If only a source path is specified the source
   * and destination is taken to be the same. The option string may be either "rbind" or "norbind" for configuring a
   * recursive or non-recursive bind mount.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#BindPaths=
   */

  #MountImages=
  /*
   * Similar to RootImage= in that it mounts a file system hierarchy from a block device node or loopback file, but
   * the destination directory can be specified as well as mount options. This option expects a whitespace separated
   * list of mount definitions. Each definition consists of a colon-separated tuple of source path and destination definitions,
   * optionally followed by another colon and a list of mount options(comma-separated list).
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#MountImages=
   */

  #ExtensionImages=
  /*
   * A whitespace separated list of mount definitions.
   * Similar to MountImages= in that it mounts a file system hierarchy from a block device node or loopback file,
   * but instead of providing a destination path, an overlay will be set up.
   * Each definition consists of a source path, optionally followed by a colon and a list of mount options.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ExtensionImages=
   */

  #ExtensionDirectories=
  /*
   * Similar to BindReadOnlyPaths= in that it mounts a file system hierarchy from a directory, but instead of
   * providing a destination path, an overlay will be set up. This option expects a whitespace separated list of source directories.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ExtensionDirectories=
   */

  ##########################
  ## User/Group Identity  ##
  ##########################

  #User=, Group= #Service runs as root user
  /*
   * Set the UNIX user or group that the processes are executed as, respectively. Takes a single user or group name, or a numeric ID
   * as argument. For system services (services run by the system service manager, i.e. managed by PID 1) and for user services of
   * the root user (services managed by root's instance of systemd --user), the default is "root", but User= may be used to specify
   * a different user. For user services of any other user, switching user identity is not permitted, hence the only valid setting
   * is the same user the user's service manager is running as. If no group is set, the default group of the user is used. This setting
   * does not affect commands whose command line is prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#User=
   */

  #DynamicUser= #Service runs as root user
  /*
   * A boolean parameter. Defaults to off. If true, a UNIX user and group pair is allocated dynamically when the unit is started, and released as soon
   * as it is stopped. The user and group will not be added to /etc/passwd or /etc/group, but are managed transiently during runtime.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#DynamicUser=
   */

  #SupplementaryGroups=
  /*
   * A space-separated list of group names or IDs.
   * Sets the supplementary Unix groups the processes are executed as. When the empty string is assigned, the list of supplementary groups is reset,
   * and all assignments prior to this one will have no effect. In any way, this option does not override, but extends the list of
   * supplementary groups configured in the system group database for the user. This does not affect commands prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SupplementaryGroups=
   */

  #PAMName=
  /*
   * Sets the PAM service name to set up a session as. If set, the executed process will be registered as a PAM session under the specified service name.
   * This is only useful in conjunction with the User= setting, and is otherwise ignored. If not set, no PAM session will be opened for the
   * executed processes. See pam(8) for details.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PAMName=
   */

  Delegate=false;
  /*
   * Turns on delegation of further resource control partitioning to processes of the unit. Units where this is enabled may create and manage their own
   * private subhierarchy of control groups below the control group of the unit itself. For unprivileged services (i.e. those using the User= setting)
   * the unit's control group will be made accessible to the relevant user.
   * When enabled the service manager will refrain from manipulating control groups or moving processes below the unit's control group, so that a
   * clear concept of ownership is established.
   * Takes either a boolean argument or a (possibly empty) list of control group controller names. If true, delegation is turned on, and all supported
   * controllers are enabled for the unit, making them available to the unit's processes for management. If false, delegation is turned off entirely.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#Delegate=
   */

  ##################
  ## Capabilities ##
  ##################

  CapabilityBoundingSet=[
    "~CAP_KILL"
    "~CAP_SYS_RAWIO"
    "~CAP_SYS_PTRACE"
    "~CAP_LEASE"
    "~CAP_SYS_PACCT"
    "~CAP_LINUX_IMMUTABLE"
    "~CAP_SYS_TTY_CONFIG"
    "~CAP_MKNOD"
    "~CAP_SYS_BOOT"
    "~CAP_SYS_CHROOT"
    "~CAP_NET_ADMIN"
    "~CAP_NET_BIND_SERVICE"
    "~CAP_NET_BROADCAST"
    "~CAP_NET_RAW"
    "~CAP_AUDIT_CONTROL"
    "~CAP_WAKE_ALARM"
    "~CAP_SYS_NICE"
  ];

  /*
   * A whitespace-separated list of capability names, e.g. CAP_SYS_ADMIN, CAP_DAC_OVERRIDE, CAP_SYS_PTRACE.
   * Controls which capabilities to include in the capability bounding set for the executed process.
   * If the list of capabilities is prefixed with "~", all but the listed capabilities will be included, the effect of the assignment inverted.
   * This does not affect commands prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#CapabilityBoundingSet=
   */

  #AmbientCapabilities=[ "CAP_BPF" "CAP_PERFMON" ];
  /*
   * Controls which capabilities to include in the ambient capability set for the executed process. Takes a whitespace-separated list of capability names,
   * e.g. CAP_SYS_ADMIN, CAP_DAC_OVERRIDE, CAP_SYS_PTRACE. This option may appear more than once, in which case the ambient capability sets are merged.
   * If the list of capabilities is prefixed with "~", all but the listed capabilities will be included, the effect of the assignment inverted.
   * If the empty string is assigned to this option, the ambient capability set is reset to the empty capability set, and all prior settings have no effect.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#AmbientCapabilities=
   */

  ##############
  ## Security ##
  ##############

  NoNewPrivileges=true;
  /*
   * A boolean argument. Defaults to false. If true, ensures that the service process and all its children can never gain new privileges through execve(). This is the
   * simplest and most effective way to ensure that a process and its children can never elevate privileges again. Certain settings override this and ignore the value
   * of this setting.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#NoNewPrivileges=
   */

  #SecureBits=
  /*
   * A space-separated combination of options from the following list: keep-caps, keep-caps-locked, no-setuid-fixup, no-setuid-fixup-locked, noroot, and noroot-locked.
   * Controls the secure bits set for the executed process. If the empty string is assigned to this option, the bits are reset to 0. This does not affect commands
   * prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SecureBits=
   */

   ##############################
   ## Mandatory Access Control ##
   ##############################

   /*
    * NOTE: In this section, options are only available for system services and are not supported for services running in per-user instances of the service manager.
	*/

  #SELinuxContext=
  /*
   * Set the SELinux security context of the executed process. If set, this will override the automated domain transition. However, the policy still needs to
   * authorize the transition. This directive is ignored if SELinux is disabled. If prefixed by "-", failing to set the SELinux security context will be ignored,
   * but it's still possible that the subsequent execve() may fail if the policy doesn't allow the transition for the non-overridden context.
   * This does not affect commands prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SELinuxContext=
   */

  #AppArmorProfile=
  /*
   * Takes a profile name as argument. The process executed by the unit will switch to this profile when started. Profiles must already be loaded in the kernel,
   * or the unit will fail. If prefixed by "-", all errors will be ignored. This setting has no effect if AppArmor is not enabled.
   * This setting does not affect commands prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#AppArmorProfile=
   */

  #SmackProcessLabel=
  /*
   * Takes a SMACK64 security label as argument. The process executed by the unit will be started under this label and SMACK will decide whether the process
   * is allowed to run or not, based on it. The process will continue to run under the label specified here unless the executable has its own SMACK64EXEC label,
   * in which case the process will transition to run under that label. When not specified, the label that systemd is running under is used. This directive is
   * ignored if SMACK is disabled. The value may be prefixed by "-", in which case all errors will be ignored.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SmackProcessLabel=
   */

  ########################
  ## Process Properties ##
  ########################

  #LimitCPU=, LimitFSIZE=, LimitDATA=, LimitSTACK=, LimitCORE=, LimitRSS=, LimitNOFILE=, LimitAS=, LimitNPROC=, LimitMEMLOCK=, LimitLOCKS=, LimitSIGPENDING=,
  #LimitMSGQUEUE=, LimitNICE=, LimitRTPRIO=, LimitRTTIME=
  #LimitMEMLOCK=0;
  /*
   * Set soft and hard limits on various resources for executed processes. Process resource limits may be specified in two formats: either as single value to
   * set a specific soft and hard limit to the same value, or as colon-separated pair soft:hard to set both limits individually. Use the string infinity to
   * configure no limit on a specific resource.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LimitCPU=
   */

  #UMask=
  /*
   * Controls the file mode creation mask. Takes an access mode in octal notation.  Defaults to 0022 for system units.
   * For user units the default value is inherited from the per-user service manager. In order to change the per-user mask for all user services,
   * consider setting the UMask= setting of the user's user@.service system service instance.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#UMask=
   */

  #CoredumpFilter=
  /*
   * A whitespace-separated combination of mapping type names or numbers (with the default base 16).
   * Options: private-anonymous, shared-anonymous, private-file-backed, shared-file-backed, elf-headers, private-huge, shared-huge, private-dax,
   * shared-dax, and the special values all (all types)
   * Default: The kernel default of "private-anonymous shared-anonymous elf-headers private-huge".
   *
   * Controls which types of memory mappings will be saved if the process dumps core (using the /proc/pid/coredump_filter file).
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#CoredumpFilter=
   */

  #KeyringMode=
  /*
   * Options: inherit, private, shared.
   * Default: private for services of the system service manager and to inherit for non-service units and for services of the user service manager
   * Kernel session keyring for the service. If set to inherit no special keyring setup is done, and the kernel's default behaviour is applied.
   * If private is used a new session keyring is allocated when a service process is invoked, and it is not linked up with any user keyring.
   * This is the recommended setting for system services, as this ensures that multiple services running under the same system user ID do not share their
   * key material among each other. If shared is used a new session keyring is allocated as for private, but the user keyring of the user configured
   * with User= is linked into it, so that keys assigned to the user may be requested by the unit's processes.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#KeyringMode=
   */

  #OOMScoreAdjust=
  /*
   * Defaults to the OOM score adjustment level of the service manager itself, which is normally at 0.
   * Sets the adjustment value for the Linux kernel's Out-Of-Memory (OOM) killer score for executed processes. Takes an integer between -1000 (to disable
   * OOM killing of processes of this unit) and 1000 (to make killing of processes of this unit under memory pressure very likely).
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#OOMScoreAdjust=
   */

  #OOMPolicy=
  /*
   * Setting of service units to configure how the service manager shall react to the kernel OOM killer or systemd-oomd terminating a process of the service.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#OOMScoreAdjust=
   */

  #TimerSlackNSec=
  /*
   * Sets the timer slack in nanoseconds for the executed processes. The timer slack controls the accuracy of wake-ups triggered by timers.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TimerSlackNSec=
   */

  #Personality=
  /*
   * Controls which kernel architecture uname(2) shall report, when invoked by unit processes. Takes one of the architecture identifiers arm64, arm64-be, arm,
   * arm-be, x86, x86-64, ppc, ppc-le, ppc64, ppc64-le, s390 or s390x. Which personality architectures are supported depends on the kernel's native architecture.
   * Usually the 64-bit versions of the various system architectures support their immediate 32-bit personality architecture counterpart, but no others.
   * The personality feature is useful when running 32-bit services on a 64-bit host system. If not specified, the personality is left unmodified and thus
   * reflects the personality of the host system's kernel.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Personality=
   */

  #IgnoreSIGPIPE=
  /*
   * Boolean arguement,  If true, causes SIGPIPE to be ignored in the executed process. Defaults to true because SIGPIPE generally is useful only in shell pipelines.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#IgnoreSIGPIPE=
   */

  ################
  ## Scheduling ##
  ################

  #Nice=
  /*
   * Sets the default nice level (scheduling priority) for executed processes.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Nice=
   */

  #CPUSchedulingPolicy=
  /*
   * Options: other, batch, idle, fifo or rr.
   * Sets the CPU scheduling policy for executed processes.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#CPUSchedulingPolicy=
   */

  #CPUSchedulingPriority=
  /*
   * Sets the CPU scheduling priority for executed processes.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#CPUSchedulingPriority=
   */

  #CPUSchedulingResetOnFork=
  /*
   * Boolean argument.
   * Default: false.
   * If true, elevated CPU scheduling priorities and policies will be reset when the executed processes call fork(2), and can hence not leak into child processes.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#CPUSchedulingPriority=
   */

  #CPUAffinity=
  /*
   * Controls the CPU affinity of the executed processes. Takes a list of CPU indices or ranges separated by either whitespace or commas.
   * Alternatively, takes a special "numa" value in which case systemd automatically derives allowed CPU range based on the value of NUMAMask= option.
   * CPU ranges are specified by the lower and upper CPU indices separated by a dash.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#CPUAffinity=
   */

  #NUMAPolicy=
  /*
   * Options: default, preferred, bind, interleave and local
   * Controls the NUMA memory policy of the executed processes. A list of NUMA nodes that should be associated with the policy must be specified in NUMAMask=.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#NUMAPolicy=
   */

  #NUMAMask=
  /*
   * Controls the NUMA node list which will be applied alongside with selected NUMA policy. Takes a list of NUMA nodes and has the same syntax as a list of
   * CPUs for CPUAffinity= option or special "all" value which will include all available NUMA nodes in the mask. Note that the list of NUMA nodes is not
   * required for default and local policies and for preferred policy we expect a single NUMA node.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#NUMAMask=
   */

  #IOSchedulingClass=
  /*
   * Sets the I/O scheduling class for executed processes. Takes one of the strings realtime, best-effort or idle. The kernel's default scheduling class is
   * best-effort at a priority of 4. If the empty string is assigned to this option, all prior assignments to both IOSchedulingClass= and
   * IOSchedulingPriority= have no effect.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#IOSchedulingClass=
   */

  #IOSchedulingPriority=
  /*
   * Sets the I/O scheduling priority for executed processes. Takes an integer between 0 (highest priority) and 7 (lowest priority).
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#IOSchedulingPriority=
   */

  ################
  ## Sandboxing ##
  ################

  /*
   * NOTE: The following sandboxing options are an effective way to limit the exposure of the system towards the unit's processes. It is recommended to turn on as
   * many of these options for each unit as is possible without negatively affecting the process' ability to operate. Note that many of these sandboxing
   * features are gracefully turned off on systems where the underlying security mechanism is not available.
   * Also note that some sandboxing functionality is generally not available in user services (i.e. services run by the per-user service manager).
   */

  #ProtectSystem= #Service runs in special boot phase, option is not appropriate
  /*
   * A boolean argument or the special values "full" or "strict".
   * Default: false.
   * If true, mounts the /usr/ and the boot loader directories (/boot and /efi) read-only for processes invoked by this unit. If set to "full", the /etc/ directory
   * is mounted read-only, too. If set to "strict" the entire file system hierarchy is mounted read-only, except for the API file system subtrees /dev/, /proc/ and
   * /sys/. It is recommended to enable this setting for all long-running services, unless they are involved with system updates or need to modify the operating system in
   * other ways. If this option is used, ReadWritePaths= may be used to exclude specific directories from being made read-only. This setting is implied if DynamicUser=
   * is set. This setting cannot ensure protection in all cases. In general it has the same limitations as ReadOnlyPaths=, see below. Defaults to off.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectSystem=
   */

  #ProtectHome= #Service runs in special boot phase, option is not appropriate
  /*
   * Takes a boolean argument or the special values "read-only" or "tmpfs".
   * Default:
   * If true, the directories /home/, /root, and /run/user are made inaccessible and empty for processes invoked by this unit. If set to "read-only", the three
   * directories are made read-only instead. If set to "tmpfs", temporary file systems are mounted on the three directories in read-only mode. The value "tmpfs" is useful
   * to hide home directories not relevant to the processes invoked by the unit, while still allowing necessary directories to be made visible when listed in BindPaths=
   * or BindReadOnlyPaths=.
   * It is recommended to enable this setting for all long-running services (in particular network-facing ones), to ensure they cannot get access to private user data,
   * unless the services actually require access to the user's private data. This setting is implied if DynamicUser= is set.
   * This option is only available for system services, or for services running in per-user instances of the service manager in which case PrivateUsers= is implicitly enabled.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectHome=
   */

  #RuntimeDirectory=, StateDirectory=, CacheDirectory=, LogsDirectory=, ConfigurationDirectory=
  /*
   * A whitespace-separated list of directory names. The specified directory names must be relative, and may not include "..". If set, when the unit is started, one or more
   * directories by the specified names will be created (including their parents) below the locations defined in the following table. Also, the corresponding environment
   * variable will be defined with the full paths of the directories. If multiple directories are set, then in the environment variable the paths are concatenated with colon (":").
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RuntimeDirectory=
   */

  # RuntimeDirectoryMode=, StateDirectoryMode=, CacheDirectoryMode=, LogsDirectoryMode=, ConfigurationDirectoryMode=
  /*
   * Defaults to 0755.
   * Specifies the access mode of the directories specified in RuntimeDirectory=, StateDirectory=, CacheDirectory=, LogsDirectory=, or ConfigurationDirectory=, respectively,
   * as an octal number.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RuntimeDirectoryMode=
   */

  #RuntimeDirectoryPreserve=
  /*
   * Takes a boolean argument or restart.
   * If set to no (the default), the directories specified in RuntimeDirectory= are always removed when the service stops. If set to restart the directories are preserved when
   * the service is both automatically and manually restarted. Here, the automatic restart means the operation specified in Restart=, and manual restart means the one triggered
   * by systemctl restart foo.service. If set to yes, then the directories are not removed when the service is stopped.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RuntimeDirectoryPreserve=
   */

  #TimeoutCleanSec=
  /*
   * Configures a timeout on the clean-up operation requested through systemctl clean …. Takes the usual time values and defaults to infinity, i.e. by default no timeout is applied.
   * If a timeout is configured the clean operation will be aborted forcibly when the timeout is reached, potentially leaving resources on disk.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TimeoutCleanSec=
   */

  #ReadWritePaths=, ReadOnlyPaths=, InaccessiblePaths=, ExecPaths=, NoExecPaths=
  #ReadOnlyPaths=["/"];
  /*
   * Sets up a new file system namespace for executed processes. These options may be used to limit access a process has to the file system. Each setting takes a space-separated
   * list of paths relative to the host's root directory (i.e. the system running the service manager). Note that if paths contain symlinks, they are resolved relative to
   * the root directory set with RootDirectory=/RootImage=.
   * Paths listed in ReadWritePaths= are accessible from within the namespace with the same access modes as from outside of it.
   * Paths listed in ReadOnlyPaths= are accessible for reading only, writing will be refused even if the usual file access controls would permit this.
   * Paths listed in InaccessiblePaths= will be made inaccessible for processes inside the namespace along with everything below them in the file system hierarchy.
   * Paths listed in  NoExecPaths= are not executable even if the usual file access controls would permit this. Nest ExecPaths= inside of NoExecPaths= in order to provide
   * executable content within non-executable directories.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ReadWritePaths=
   */

  #TemporaryFileSystem=
  /*
   * Takes a space-separated list of mount points for temporary file systems (tmpfs). If set, a new file system namespace is set up for executed processes, and a temporary file system
   * is mounted on each mount point. Each mount point may optionally be suffixed with a colon (":") and mount options such as "size=10%" or "ro".
   * By default, each temporary file system is mounted with "nodev,strictatime,mode=0755".
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TemporaryFileSystem=
   */

  #PrivateTmp=
  /*
   * A boolean argument. Defaults to false.
   * If true, sets up a new file system namespace for the executed processes and mounts private /tmp/ and /var/tmp/ directories inside it that are not shared by processes outside
   * of the namespace. This is useful to secure access to temporary files of the process, but makes sharing between processes via /tmp/ or /var/tmp/ impossible.
   * If true, all temporary files created by a service in these directories will be removed after the service is stopped.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PrivateTmp=
   */

  #PrivateDevices=true;
  /*
   * A boolean argument. Defaults to false. If true, sets up a new /dev/ mount for the executed processes and only adds API pseudo devices such as /dev/null, /dev/zero or
   * /dev/random to it, but no physical devices such as /dev/sda, system memory /dev/mem, system ports /dev/port and others. This is useful to turn off physical device access
   * by the executed process. Enabling this option will install a system call filter to block low-level I/O system calls that are grouped in the @raw-io set.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PrivateDevices=
   */

  #DeviceAllow=[ "/dev/null rw" "/dev/urandom r" ];
  /*
   * Control access to specific device nodes by the executed processes. Takes two space-separated strings: a device node specifier followed by a combination of r, w, m to
   * control reading, writing, or creation of the specific device nodes by the unit (mknod), respectively. This functionality is implemented using eBPF filtering.
   * When access to all physical devices should be disallowed, PrivateDevices= may be used instead.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#DeviceAllow=
   */

  PrivateNetwork=true;
  /*
   * A boolean argument. Defaults to false. If true, sets up a new network namespace for the executed processes and configures only the loopback network device "lo" inside it.
   * No other network devices will be available to the executed process. This is useful to turn off network access by the executed process.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PrivateNetwork=
   */

  #NetworkNamespacePath=
  /*
   * Takes an absolute file system path referring to a Linux network namespace pseudo-file. When set the invoked processes are added to the network namespace referenced by
   * that path. The path has to point to a valid namespace file at the moment the processes are forked off. If this option is used PrivateNetwork= has no effect.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#NetworkNamespacePath=
   */

  #PrivateIPC=
  /*
   * A boolean argument. Defaults to false. If true, sets up a new IPC namespace for the executed processes. Each IPC namespace has its own set of System V IPC identifiers
   * and its own POSIX message queue file system. This is useful to avoid name clash of IPC identifiers.  Note that IPC namespacing does not have an effect on AF_UNIX sockets,
   * which are the most common form of IPC used on Linux.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PrivateIPC=
   */

  #IPCNamespacePath=
  /*
   * An absolute file system path referring to a Linux IPC namespace pseudo-file. When set the invoked processes are added to the network namespace referenced by that path.
   * The path has to point to a valid namespace file at the moment the processes are forked off. If this option is used PrivateIPC= has no effect.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#IPCNamespacePath=
   */

  #MemoryKSM=
  /*
   * A boolean argument. Defaults to false. When set, it enables KSM (kernel samepage merging) for the processes. KSM is a memory-saving de-duplication feature.
   * Anonymous memory pages with identical content can be replaced by a single write-protected page. This feature should only be enabled for jobs that share the same security domain.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#MemoryKSM=
   */

  #PrivateUsers=true;
  /*
   * A boolean argument. If true, sets up a new user namespace for the executed processes and configures a minimal user and group mapping, that maps the "root" user and
   * group as well as the unit's own user and group to themselves and everything else to the "nobody" user and group. This is useful to securely detach the user and group databases
   * ised by the unit from the rest of the system, and thus to create an effective sandbox environment. All files, directories, processes, IPC objects and other resources owned
   * by users/groups not equaling "root" or the unit's own will stay visible from within the unit but appear owned by the "nobody" user and group. If this mode is enabled,
   * all unit processes are run without privileges in the host user namespace. Specifically this means that the process will have zero process capabilities on the host's user namespace,
   * but full capabilities within the service's user namespace.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PrivateUsers=
   */

  ProtectHostname=true;
  /*
   * A boolean argument. Defaults to off. When set, sets up a new UTS namespace for the executed processes. In addition, changing hostname or domainname is prevented.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectHome=
   */

  ProtectClock=true;
  /*
   * A boolean argument. Defaults to off. If set, writes to the hardware clock or system clock will be denied.  Enabling this option removes CAP_SYS_TIME and CAP_WAKE_ALARM from
   * the capability bounding set for this unit, installs a system call filter to block calls that can set the clock, and DeviceAllow=char-rtc r is implied.
   * It is recommended to turn this on for most services that do not need modify the clock or check its state.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectHome=
   */

  #ProtectKernelTunables=
  /*
   * A boolean argument. Defaults to off. If true, kernel variables accessible through /proc/sys/, /sys/, /proc/sysrq-trigger, /proc/latency_stats, /proc/acpi, /proc/timer_stats, /proc/fs
   * and /proc/irq will be made read-only to all processes of the unit. Usually, tunable kernel variables should be initialized only at boot-time. Few services need to write
   * to these at runtime; it is hence recommended to turn this on for most services.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectKernelTunables=
   */

  #ProtectKernelModules=
  /*
   * A boolean argument. Defaults to off. If true, explicit module loading will be denied. This allows module load and unload operations to be turned off on modular kernels.
   * It is recommended to turn this on for most services that do not need special file systems or extra kernel modules to work.
   * Enabling this option removes CAP_SYS_MODULE from the capability bounding set for the unit, and installs a system call filter to block module system calls,
   * also /usr/lib/modules is made inaccessible.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectKernelModules=
   */

  #ProtectKernelLogs=
  /*
   * A boolean argument. Default is off. If true, access to the kernel log ring buffer will be denied.
   * It is recommended to turn this on for most services that do not need to read from or write to the kernel log ring buffer. Enabling this option removes CAP_SYSLOG
   * from the capability bounding set for this unit, and installs a system call filter to block the syslog(2) system call. The kernel exposes its log buffer to userspace via
   * /dev/kmsg and /proc/kmsg. If enabled, these are made inaccessible to all the processes in the unit.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectKernelLogs=
   */

  #ProtectControlGroups=
  /*
   * A boolean argument. Defaults to off. If true, the Linux Control Groups (cgroups(7)) hierarchies accessible through /sys/fs/cgroup/ will be made read-only to all processes of the unit.
   * It is hence recommended to turn this on for most services.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ProtectControlGroups=
   */

  RestrictAddressFamilies=["~AF_PACKET" "~AF_NETLINK" "~AF_INET" "~AF_INET6"];
  /*
   * Options: "none", or a space-separated list of address family names to allow-list, such as AF_UNIX, AF_INET or AF_INET6.
   * Restricts the set of socket address families accessible to the processes of this unit. When "none" is specified, then all address families will be denied.
   * When prefixed with "~" the listed address families will be applied as deny list, otherwise as allow list. Note that this restricts access to the socket(2) system call only.
   * By default, no restrictions apply, all address families are accessible to processes. This setting does not affect commands prefixed with "+".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RestrictAddressFamilies=
   */

  #RestrictFileSystems=
  /*
   * A space-separated list of filesystem names. Restricts the set of filesystems processes of this unit can open files on. Any filesystem listed is made accessible to
   * the unit's processes, access to filesystem types not listed is prohibited. If the first character of the list is "~", the effect is inverted
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RestrictFileSystems=
   */

  RestrictNamespaces=true;
  /*
   * Boolean argument, or a space-separated list of namespace type identifiers. Defaults to false.
   * Restricts access to Linux namespace functionality for the processes of this unit. If false, no restrictions on namespace creation and switching are made.
   * If true, access to any kind of namespacing is prohibited. Otherwise, a space-separated list of namespace type identifiers must be specified, consisting of any combination
   * of: cgroup, ipc, net, mnt, pid, user and uts.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RestrictNamespaces=
   */

  LockPersonality=true;
  /*
   * A boolean argument. Defaults to false.
   * If set, locks down the personality system call so that the kernel execution domain may not be changed from the default or the personality selected with Personality= directive.
   * This may be useful to improve security, because odd personality emulations may be poorly tested and source of vulnerabilities. If running in user mode, or in system mode,
   * but without the CAP_SYS_ADMIN capability (e.g. setting User=), NoNewPrivileges=yes is implied.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LockPersonality=
   */

  MemoryDenyWriteExecute=true;
  /*
   * A boolean argument. Default is false,
   * If set, attempts to create memory mappings that are writable and executable at the same time, or to change existing memory mappings to become executable, or mapping shared
   * memory segments as executable, are prohibited. Specifically, appropriate system call filter is added.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#MemoryDenyWriteExecute=
   */

  RestrictRealtime=true;
  /*
   * A boolean argument. Default is false.
   * If set, any attempts to enable realtime scheduling in a process of the unit are refused. This restricts access to realtime task scheduling policies such as SCHED_FIFO,
   * SCHED_RR or SCHED_DEADLINE. If running in user mode, or in system mode, but without the CAP_SYS_ADMIN capability, NoNewPrivileges=yes is implied.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RestrictRealtime=
   */

  #RestrictSUIDSGID=
  /*
   * A boolean argument. Defaults to off. If set, any attempts to set the set-user-ID (SUID) or set-group-ID (SGID) bits on files or directories will be denied. If running in user mode, or in
   * system mode, but without the CAP_SYS_ADMIN capability, NoNewPrivileges=yes is implied. As the SUID/SGID bits are mechanisms to elevate privileges, and allow users to
   * acquire the identity of other users, it is recommended to restrict creation of SUID/SGID files to the few programs that actually require them.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RestrictSUIDSGID=
   */

  #RemoveIPC=
  /*
   * A boolean parameter. Defaults to off. If set, all System V and POSIX IPC objects owned by the user and group the processes of this unit are run as are removed when the unit is stopped.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#RemoveIPC=
   */

  #PrivateMounts=
  /*
   * A boolean parameter. Defaults to off.
   * If set, the processes of this unit will be run in their own private file system (mount) namespace with all mount propagation from the processes towards the
   * host's main file system namespace turned off. This means any file system mount points established or removed by the unit's processes will be private to them and not be visible to the host.
   * However, file system mount points established or removed on the host will be propagated to the unit's processes.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PrivateMounts=
   */

  #MountFlags=
  /*
   * Options: (mount propagation setting) shared, slave or private
   * Controls whether file system mount points in the file system namespaces set up for this unit's processes will receive or propagate mounts and unmounts from other file system namespaces.
   * Usually, it is best to leave this setting unmodified, and use higher level file system namespacing options instead, in particular PrivateMounts=.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#MountFlags=
   */

###########################
## System Call Filtering ##
###########################

  SystemCallFilter=[
    "~@debug"
    "~@obsolete"
    "~@reboot"
    "~@cpu-emulation"
    "~@privileged"
    "~@swap"
    "~@resources"
    "~@raw-io"
   ];
  /*
   * A space-separated list of system call names. If this setting is used, all system calls executed by the unit processes except for the listed ones will result in immediate process termination
   * with the SIGSYS signal (allow-listing). If the first character of the list is "~", the effect is inverted.
   * As the number of possible system calls is large, predefined sets of system calls are provided. A set starts with "@" character, followed by name of the set.
   * Predefined system call sets:
   * Set	Description
   * @aio	Asynchronous I/O (io_setup(2), io_submit(2), and related calls)
   * @basic-io	System calls for basic I/O: reading, writing, seeking, file descriptor duplication and closing (read(2), write(2), and related calls)
   * @chown	Changing file ownership (chown(2), fchownat(2), and related calls)
   * @clock	System calls for changing the system clock (adjtimex(2), settimeofday(2), and related calls)
   * @cpu-emulation	System calls for CPU emulation functionality (vm86(2) and related calls)
   * @debug	Debugging, performance monitoring and tracing functionality (ptrace(2), perf_event_open(2) and related calls)
   * @file-system	File system operations: opening, creating files and directories for read and write, renaming and removing them, reading file properties, or creating hard and symbolic links
   * @io-event	Event loop system calls (poll(2), select(2), epoll(7), eventfd(2) and related calls)
   * @ipc	Pipes, SysV IPC, POSIX Message Queues and other IPC (mq_overview(7), svipc(7))
   * @keyring	Kernel keyring access (keyctl(2) and related calls)
   * @memlock	Locking of memory in RAM (mlock(2), mlockall(2) and related calls)
   * @module	Loading and unloading of kernel modules (init_module(2), delete_module(2) and related calls)
   * @mount	Mounting and unmounting of file systems (mount(2), chroot(2), and related calls)
   * @network-io	Socket I/O (including local AF_UNIX): socket(7), unix(7)
   * @obsolete	Unusual, obsolete or unimplemented (create_module(2), gtty(2), …)
   * @pkey	System calls that deal with memory protection keys (pkeys(7))
   * @privileged	All system calls which need super-user capabilities (capabilities(7))
   * @process	Process control, execution, namespacing operations (clone(2), kill(2), namespaces(7), …)
   * @raw-io	Raw I/O port access (ioperm(2), iopl(2), pciconfig_read(), …)
   * @reboot	System calls for rebooting and reboot preparation (reboot(2), kexec(), …)
   * @resources	System calls for changing resource limits, memory and scheduling parameters (setrlimit(2), setpriority(2), …)
   * @sandbox	System calls for sandboxing programs (seccomp(2), Landlock system calls, …)
   * @setuid	System calls for changing user ID and group ID credentials, (setuid(2), setgid(2), setresuid(2), …)
   * @signal	System calls for manipulating and handling process signals (signal(2), sigprocmask(2), …)
   * @swap	System calls for enabling/disabling swap devices (swapon(2), swapoff(2))
   * @sync	Synchronizing files and memory to disk (fsync(2), msync(2), and related calls)
   * @system-service	A reasonable set of system calls used by common system services, excluding any special purpose calls. This is the recommended starting point for allow-listing system calls for
   *  system services, as it contains what is typically needed by system services, but excludes overly specific interfaces. For example, the following APIs are excluded: "@clock", "@mount", "@swap", "@reboot".
   * @timer	System calls for scheduling operations by time (alarm(2), timer_create(2), …)
   * @known	All system calls defined by the kernel. This list is defined statically in systemd based on a kernel version that was available when this systemd version was released. It will become
   *  progressively more out-of-date as the kernel is updated.
   * Note, that as new system calls are added to the kernel, additional system calls might be added to the groups above.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SystemCallFilter=
   */

  #SystemCallErrorNumber=
  /*
   * Takes an "errno" error number (between 1 and 4095) or errno name such as EPERM, EACCES or EUCLEAN, to return when the system call filter configured with SystemCallFilter= is triggered, instead of
   * terminating the process immediately.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SystemCallErrorNumber=
   */

  SystemCallArchitectures="native";
  /*
   * Takes a space-separated list of architecture identifiers to include in the system call filter. If running in user mode, or in system mode, but without the CAP_SYS_ADMIN capability, NoNewPrivileges=yes
   * is implied. By default, this option is set to the empty list, i.e. no filtering is applied.
   * If this setting is used, processes of this unit will only be permitted to call native system calls, and system calls of the specified architectures.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SystemCallArchitectures=
   */

  #SystemCallLog=
  /*
   * A space-separated list of system call names. If this setting is used, all system calls executed by the unit processes for the listed ones will be logged. If the first character of the list is "~",
   * the effect is inverted. If running in user mode, or in system mode, but without the CAP_SYS_ADMIN capability, NoNewPrivileges=yes is implied.
   * This feature makes use of the Secure Computing Mode 2 interfaces of the kernel and is useful for auditing or setting up a minimal sandboxing environment.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SystemCallLog=
   */

#################
## Environment ##
#################

  #Environment=
  /*
   * Sets environment variables for executed processes. If you need to assign a value containing spaces or the equals sign to a variable, put quotes around the whole assignment. Variable expansion is not
   * performed inside the strings and the "$" character has no special meaning. Specifier expansion is performed.
   * The names of the variables can contain ASCII letters, digits, and the underscore character. Variable names cannot be empty or start with a digit.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Environment=
   */

  #EnvironmentFile=
  /*
   * Similar to Environment=, but reads the environment variables from a text file.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#EnvironmentFile=
   */

  #PassEnvironment=
  /*
   * Pass environment variables set for the system service manager to executed processes. Takes a space-separated list of variable names. This option may be specified more than once,
   * in which case all listed variables will be passed. If the empty string is assigned to this option, the list of environment variables to pass is reset, all prior assignments have no effect.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#PassEnvironment=
   */

  #UnsetEnvironment=
  /*
   * Explicitly unset environment variable assignments that would normally be passed from the service manager to invoked processes of this unit. Takes a space-separated list of variable names
   * or variable assignments.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#UnsetEnvironment=
   */

########################################
## Logging and Standard Input/Output  ##
########################################

  #StandardInput=
  /*
   * Options: null, tty, tty-force, tty-fail, data, file:path, socket or fd:name.
   * Defaults to null.
   * Controls where file descriptor 0 (STDIN) of the executed processes is connected to. If null is selected, standard input will be connected to /dev/null,
   * i.e. all read attempts by the process will result in immediate EOF.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#StandardInput=
   */

  #StandardOutput=
  /*
   * Options: inherit, null, tty, journal, kmsg, journal+console, kmsg+console, file:path, append:path, truncate:path, socket or fd:name
   * Defaults to inherit.
   * Controls where file descriptor 1 (stdout) of the executed processes is connected to. Takes one of inherit, null, tty, journal, kmsg, journal+console, kmsg+console, file:path, append:path,
   * truncate:path, socket or fd:name.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#StandardOutput=
   */

  #StandardError=
  /*
   * Controls where file descriptor 2 (stderr) of the executed processes is connected to. The available options are identical to those of StandardOutput=, with some exceptions
   * This setting defaults to the value set with DefaultStandardError= in , which defaults to inherit.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#StandardError=
   */

  #StandardInputText=, StandardInputData=
  /*
   * Configures arbitrary textual or binary data to pass via file descriptor 0 (STDIN) to the executed processes.
   * These settings have no effect unless StandardInput= is set to data (which is the default if StandardInput= is not set otherwise, but StandardInputText=/StandardInputData= is).
   * StandardInputText= accepts arbitrary textual data. C-style escapes for special characters as well as the usual "%"-specifiers are resolved.
   * StandardInputData= accepts arbitrary binary data, encoded in Base64. No escape sequences or specifiers are resolved. Any whitespace in the encoded version is ignored during decoding.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#StandardInputText=
   */

  #LogLevelMax=
  /*
   * Configures filtering by log level of log messages generated by this unit. Takes a syslog log level, one of emerg (lowest log level, only highest priority messages), alert, crit, err,
   * warning, notice, info, debug (highest log level, also lowest priority messages).
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogLevelMax=
   */

  #LogExtraFields=
  /*
   * Configures additional log metadata fields to include in all log records generated by processes associated with this unit, including systemd.
   * This setting takes one or more journal field assignments in the format "FIELD=VALUE" separated by whitespace.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogExtraFields=
   */

  #LogRateLimitIntervalSec=, LogRateLimitBurst=
  /*
   * Configures the rate limiting that is applied to log messages generated by this unit. If, in the time interval defined by LogRateLimitIntervalSec=, more messages than specified in
   * LogRateLimitBurst= are logged by a service, all further messages within the interval are dropped until the interval is over.
   * A message about the number of dropped messages is generated. The time specification for LogRateLimitIntervalSec= may be specified in the following units: "s", "min", "h", "ms", "us".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogRateLimitIntervalSec=
   */

  #LogFilterPatterns=
  /*
   * Define an extended regular expression to filter log messages based on the MESSAGE= field of the structured message. If the first character of the pattern is "~",
   * log entries matching the pattern should be discarded. This option takes a single pattern as an argument but can be used multiple times to create a list of allowed and denied patterns.
   * Log messages are tested against denied patterns (if any), then against allowed patterns (if any). If a log message matches any of the denied patterns, it will be discarded,
   * whatever the allowed patterns. Then, remaining log messages are tested against allowed patterns. Messages matching against none of the allowed pattern are discarded.
   * If no allowed patterns are defined, then all messages are processed directly after going through denied filters.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogFilterPatterns=
   */

  #LogNamespace=
  /*
   * Run the unit's processes in the specified journal namespace. Expects a short user-defined string identifying the namespace. If not used the processes of the service are run in the
   * default journal namespace, i.e. their log stream is collected and processed by systemd-journald.service.
   * This option is only available for system services.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LogNamespace=
   */
  #SyslogIdentifier=
  /*
   *
   * Sets the process name ("syslog tag") to prefix log lines sent to the logging system or the kernel log buffer with. If not set, defaults to the process name of the executed process.
   * This option is only useful when StandardOutput= or StandardError= are set to journal or kmsg  and only applies to log messages written to stdout or stderr.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SyslogIdentifier=
   */

  #SyslogFacility=
  /*
   * Sets the syslog facility identifier to use when logging. One of kern, user, mail, daemon, auth, syslog, lpr, news, uucp, cron, authpriv, ftp, local0, local1, local2, local3,
   * local4, local5, local6 or local7.  This option is only useful when StandardOutput= or StandardError= are set to journal or kmsg and only applies to log messages written
   * to stdout or stderr.
   * Defaults to daemon.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SyslogFacility=
   */

  #SyslogLevel=
  /*
   * The default syslog log level to use when logging to the logging system or the kernel log buffer. One of emerg, alert, crit, err, warning, notice, info, debug.
   * This option is only useful when StandardOutput= or StandardError= are set to journal or kmsg, and only applies to log messages written to stdout or stderr.
   * Defaults to info.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SyslogLevel=
   */

  #SyslogLevelPrefix=
  /*
   * A boolean argument. Defaults to true. If true and StandardOutput= or StandardError= are set to journal or kmsg, log lines written by the executed process that are prefixed with a log level will
   * be processed with this log level set but the prefix removed. If set to false, the interpretation of these prefixes is disabled and the logged lines are passed on as-is.
   * This only applies to log messages written to stdout or stderr.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#SyslogLevelPrefix=
   */

  #TTYPath=
  /*
   * Sets the terminal device node to use if standard input, output, or error are connected to a TTY. Defaults to /dev/console.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TTYPath=
   */

  #TTYReset=
  /*
   * Reset the terminal device specified with TTYPath= before and after execution. Defaults to "no".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TTYReset=
   */

  #TTYVHangup=
  /*
   * Disconnect all clients which have opened the terminal device specified with TTYPath= before and after execution. Defaults to "no".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TTYVHangup=
   */

  #TTYRows=, TTYColumns=
  /*
   * Configure the size of the TTY specified with TTYPath=. If unset or set to the empty string, the kernel default is used.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TTYRows=
   */

  #TTYVTDisallocate=
  /*
   * If the terminal device specified with TTYPath= is a virtual console terminal, try to deallocate the TTY before and after execution.
   * This ensures that the screen and scrollback buffer is cleared.
   * Defaults to "no".
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#TTYVTDisallocate=
   */

#################
## Credentials ##
#################

  #LoadCredential=ID[:PATH], LoadCredentialEncrypted=ID[:PATH]
  /*
   * Pass a credential to the unit. Credentials are limited-size binary or textual objects that may be passed to unit processes.
   * They are primarily used for passing cryptographic keys (both public and private) or certificates, user account information or identity information from host to services.
   * The data is accessible from the unit's processes via the file system, at a read-only location that (if possible and permitted) is backed by non-swappable memory.
   * The LoadCredential= setting takes a textual ID to use as name for a credential plus a file system path, separated by a colon.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#LoadCredential=
   */

  #ImportCredential=GLOB
  /*
   * Pass one or more credentials to the unit. Takes a credential name for which we'll attempt to find a credential that the service manager itself received under
   * the specified name — which may be used to propagate credentials from an invoking environment into a service. If the credential name is a glob, all credentials matching
   * the glob are passed to the unit. Matching credentials are searched for in the system credentials, the encrypted system credentials, and under /etc/credstore/,
   * /run/credstore/, /usr/lib/credstore/, /run/credstore.encrypted/, /etc/credstore.encrypted/, and /usr/lib/credstore.encrypted/ in that order.
   * When multiple credentials of the same name are found, the first one found is used.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.exec.html#ImportCredential=
   */

####################################
## Network Accounting and Control ##
####################################

  #IPAccounting=true;
  /*
   * A boolean argument. Defaults to false. If true, turns on IPv4 and IPv6 network traffic accounting for packets sent or received by the unit.
   * When this option is turned on, all IPv4 and IPv6 sockets created by any process of the unit are accounted for.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#IPAccounting=
   */

  #IPAddressAllow=ADDRESS[/PREFIXLENGTH]…, IPAddressDeny=ADDRESS[/PREFIXLENGTH]…
  IPAddressDeny="any";
  /*
   * Turn on network traffic filtering for IP packets sent and received over AF_INET and AF_INET6 sockets. Both directives take a space separated list of
   * IPv4 or IPv6 addresses, each optionally suffixed with an address prefix length in bits after a "/" character. If the suffix is omitted, the
   * address is considered a host address.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#IPAddressAllow=
   */

  #RestrictNetworkInterfaces=
  /*
   * Takes a list of space-separated network interface names. This option restricts the network interfaces that processes of this unit can use.
   * By default processes can only use the network interfaces listed. If the first character of the rule is "~", the effect is inverted.
   * The loopback interface ("lo") is not treated in any special way, you have to configure it explicitly in the unit file.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#RestrictNetworkInterfaces=
   */

##################
## BPF Programs ##
##################

  #IPIngressFilterPath=BPF_FS_PROGRAM_PATH, IPEgressFilterPath=BPF_FS_PROGRAM_PATH
  /*
   * Add custom network traffic filters implemented as BPF programs, applying to all IP packets sent and received over AF_INET and AF_INET6 sockets.
   * Takes an absolute path to a pinned BPF program in the BPF virtual filesystem (/sys/fs/bpf/).
   * The filters configured with this option are applied to all sockets created by processes of this unit. By default there are no filters specified.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#IPIngressFilterPath=
   */

  #BPFProgram=type:program-path
  /*
   * Allows attaching custom BPF programs to the cgroup of a unit. (This generalizes the functionality exposed via IPEgressFilterPath= and IPIngressFilterPath= for other hooks.)
   * Cgroup-bpf hooks in the form of BPF programs loaded to the BPF filesystem are attached with cgroup-bpf attach flags determined by the unit.
   * For details refer to the general BPF documentation.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#BPFProgram=
   */

#################
## CPU Control ##
#################

  #AllowedCPUs=, StartupAllowedCPUs=
  /*
   * Restrict processes to be executed on specific CPUs. Takes a list of CPU indices or ranges separated by either whitespace or commas. CPU ranges are specified by the lower
   * and upper CPU indices separated by a dash. Setting AllowedCPUs= or StartupAllowedCPUs= doesn't guarantee that all of the CPUs will be used by the processes as it may be
   * limited by parent units. The effective configuration is reported as EffectiveCPUs=.
   * While StartupAllowedCPUs= applies to the startup and shutdown phases of the system, AllowedCPUs= applies to normal runtime of the system, and if the former is not set
   * also to the startup and shutdown phases. Using StartupAllowedCPUs= allows prioritizing specific services at boot-up and shutdown differently than during normal runtime.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#AllowedCPUs=
   */

###################################
## Memory Accounting and Control ##
###################################

  #MemoryMin=bytes, MemoryLow=bytes, StartupMemoryLow=bytes, DefaultStartupMemoryLow=bytes
  /*
   * Specify the memory usage protection of the executed processes in this unit. When reclaiming memory, the unit is treated as if it was using less memory resulting in memory to
   * be preferentially reclaimed from unprotected units. Using MemoryLow= results in a weaker protection where memory may still be reclaimed to avoid invoking the OOM killer in
   * case there is no other reclaimable memory.
   * For a protection to be effective, it is generally required to set a corresponding allocation on all ancestors, which is then distributed between children.
   * Any MemoryMin= or MemoryLow= allocation that is not explicitly distributed to specific children is used to create a shared protection for all children. As this is a shared protection,
   * the children will freely compete for the memory.
   * Takes a memory size in bytes. If the value is suffixed with K, M, G or T, the specified memory size is parsed as Kilobytes, Megabytes, Gigabytes, or Terabytes respectively.
   * Alternatively, a percentage value may be specified, which is taken relative to the installed physical memory on the system.
   * While StartupMemoryLow= applies to the startup and shutdown phases of the system, MemoryMin= applies to normal runtime of the system, and if the former is not set also to the
   * startup and shutdown phases.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#MemoryMin=
   */

  #MemoryHigh=bytes, StartupMemoryHigh=bytes
  /*
   * Specify the throttling limit on memory usage of the executed processes in this unit. Memory usage may go above the limit if unavoidable, but the processes are heavily slowed down
   * and memory is taken away aggressively in such cases. This is the main mechanism to control memory usage of a unit.
   * For usage refer MemoryMin syntax.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#MemoryHigh=
   */

  #MemoryMax=bytes, StartupMemoryMax=bytes

  /*
   * Specify the absolute limit on memory usage of the executed processes in this unit. If memory usage cannot be contained under the limit, out-of-memory killer is invoked inside the
   * unit. It is recommended to use MemoryHigh= as the main control mechanism and use MemoryMax= as the last line of defense.
   * For usage refer MemoryMin syntax.
   *
   * https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#MemoryMax=
   */
}

