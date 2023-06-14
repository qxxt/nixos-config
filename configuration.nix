# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  nix.settings.auto-optimise-store = true;

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;

  # Setup keyfile
  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

  # Enable grub cryptodisk
  boot.loader.grub.enableCryptodisk = true;

  boot.initrd.luks.devices = {
    "luks-86e2a2b1-f50f-4633-9bc1-1470e768d3a4".keyFile = "/crypto_keyfile.bin";
    # Enable swap on luks
    "luks-5f562c5d-5b0b-4974-a878-faabd2b985b2".device =
      "/dev/disk/by-uuid/5f562c5d-5b0b-4974-a878-faabd2b985b2";
    "luks-5f562c5d-5b0b-4974-a878-faabd2b985b2".keyFile = "/crypto_keyfile.bin";
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.foobar = {
    isNormalUser = true;
    description = "";
    home = "/home/foobar";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      tor-browser-bundle-bin
      nixfmt
      telegram-desktop
      rclone
      sbcl
      ccls
      docker
      docker-compose
      ruby
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    emacs-gtk
    firefox
    git
    vsftpd
    go
    keepassxc
    nil
    gparted
    nix-output-monitor
    python3
    darkhttpd
    openssl
    xclip
  ];

  virtualisation.docker.enable = true;

  # vsftpd
  networking.firewall.allowedTCPPorts = [ 3176 ];
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    userlistEnable = true;
    userlist = [ "foobar" ];

    rsaKeyFile = "/etc/ssl/private/vsftpd.key";
    rsaCertFile = "/etc/ssl/certs/vsftpd.crt";
    forceLocalLoginsSSL = true;
    forceLocalDataSSL = true;

    extraConfig = ''
      pasv_enable=Yes
      pasv_min_port=51000
      pasv_max_port=51999
      listen_port=3176

      ssl_enable=YES
      # If set to yes, all SSL data connections are required to
      # exhibit SSL session reuse (which proves that they know the
      # same master secret as the control channel). Although this is a
      # secure default, it may break many FTP clients, so you may want
      # to disable it. For a discussion of the consequences, see
      # http://scarybeastsecurity.blogspot.com/2009/02/vsftpd-210-released.html
      # (Added in v2.1.0).
      require_ssl_reuse=NO
      ssl_ciphers=HIGH

      max_clients=20
    '';
  };

  networking.firewall.allowedTCPPortRanges = [{
    from = 51000;
    to = 51999;
  }];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
