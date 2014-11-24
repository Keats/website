# This is a nixops config file describing the *logical* setup of our
# server. The actual physical instantiation lives in a local sqlite
# database and can be imported like this:
# nixops import -s ~/.nixops/deployments.nixops < instantiated.json
#
# You'll also need to export the secret key like this:
# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_ACCESS_KEY=...
let
    region = "eu-west-1";

in
{
    resources.ec2KeyPairs.waw-pair =
        { inherit region; };

    resources.ec2SecurityGroups.http-ssh = {
        inherit region;
        rules = [
            { fromPort = 22; toPort = 22; sourceIp = "0.0.0.0/0"; }
            { fromPort = 80; toPort = 80; sourceIp = "0.0.0.0/0"; }
            { fromPort = 443; toPort = 443; sourceIp = "0.0.0.0/0"; }
        ];
    };

    webserver = { resources, pkgs, lib, ... }:
        let
        website_html = pkgs.callPackage ./website.nix {};
        wearewizards_certs = pkgs.callPackage ./wearewizards_certs.nix {};

        in {
        deployment.targetEnv = "ec2";
        deployment.ec2.region = region;
        deployment.ec2.instanceType = "m3.medium";
        deployment.ec2.keyPair = resources.ec2KeyPairs.waw-pair;
        deployment.ec2.spotInstancePrice = 2;
        deployment.ec2.securityGroups = [ resources.ec2SecurityGroups.http-ssh ];

        # Enable a basic firewall
        networking.firewall.enable = true;
        networking.firewall.allowedTCPPorts = [ 22 80 443 ];
        networking.firewall.allowPing = true;

        # Set up ssh keys for git-pushing
        users.extraUsers.root.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8qophzPjWSo0UG3uZyibdz0ffI1xbEpP4GBBBIF70Q/Zg29ccDYWap/4SCF6JAwPB6cCsodGUCEyOhk9zj8kCQZB4+5oKVAR+9fBDA/+AGDnekFF+9EUEBXCZjfIaIwQlj1ogEnpRjo8aJWlqj4Q2NJ3vZmjG9PKuDxGu5wnj1Q9QH1Z5XiknwzcyhkH/PEMQIywYhS7g4gRzE68cdzZViOiQCT7/cLRZpzk0YjjsTPDScAQlcwMZgVOAAZa202ZjFjAck3nVcQQ1fUjUCRNH+zcNp0pp5im3pD6pdQKvai8Po0g/iPitOiz8H7UMRWZjeEgQaKZ2J+vDyPlq95MR vincent@wearewizards.io"
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtq8LpgrnFQWpIcK5YdrQNzu22sPrbkHKD83g8v/s7Nu3Omb7h5TLBOZ6DYPSorGMKGjDFqo0witXRagWq95HaA9epFXmhJlO3NTxyTAzIZSzql+oJkqszNpmYY09L00EIplE/YKXPlY2a+sGx3CdJxbglGfTcqf0J2DW4wO2ikZSOXRiLEbztyDwc+TNwYJ3WtzTFWhG/9hbbHGZtpwQl6X5l5d2Mhl2tlKJ/zQYWV1CVXLSyKhkb4cQPkL05enguCQgijuI/WsUE6pqdl4ypziXGjlHAfH+zO06s6EDMQYr50xgYRuCBicF86GF8/fOuDJS5CJ8/FWr16fiWLa2Aw== tom@wearewizards.io"
        ];

        environment.systemPackages = [ pkgs.git ];

        # We want to ssh in but keep annoying people out
        services.openssh.enable = true;
        services.fail2ban.enable = true;

        # Our website is just static content:
        services.nginx.enable = true;
        services.nginx.config = ''
        events { }
        http {
        include ${pkgs.nginx}/conf/mime.types;
        server {
          listen          80;
          listen          443 ssl;
          server_name     wearewizards.io;

          ssl_certificate ${wearewizards_certs}/bundle.crt;
          ssl_certificate_key ${wearewizards_certs}/wearewizards.io.key;

          location / {
              root ${website_html}/html;
          }
        }
        server {
          listen          80;
          listen          443;

          location / {
              root /var/www/blog;
          }
        }
        }
        '';
    };
}