
# Introduction:
This service provides SSL VPN available on port 443 TCP. It also uses 443 UDP for DTLS connectivity.

Certificates are self signed by default and will require security setting modification within the client side. 
Valid certificates can be installed manually if required. More details on this can be found later on.


# Required Configuration:
This service requires some minor customisation to use effectively.

## Route Details:
* The only mandatory options which should be changed is the 'route' directive.
* This is found in the /vpn.conf file.
* This expects that routes are already installed on the linux host to access any attached subnets

## VPN Client Pool:
* The VPN client pool is by default 10.0.150.0/24. This should not need to be changed, outbound connectivity it NAT'd so no routes to this subnet are required.
* This can be changed, and it MUST be changed in both /vpn.conf and /vpn-init.sh 

## Users:
* Users must be configured in the /users.conf
* The default username is 'admin' with password 'password'
* Passwords are stored using the 'crypt' hash algorithm
* Users can be added / removed without restarting the service
* The file MUST have a newline at the end of the file!
* User format is '<user>:*:<crypt password>' the asterisk and colons are required
* This is NOT designed for security! Anybody who have access to the webgui can add themselves as a user!!
* If security is a concern, limit access to the webgui at port 8080

## Certificates:
* Default certs are self signed
* Valid certificates can be installed
* Certificate is contained in /certs/server.crypt
* Private key is at /certs/server.key
* Certificate chain is at /certs/server.key.orig
The following commands were used to generate the default certs:
    openssl rand -base64 48 > passphrase.txt
    openssl genrsa -aes128 -passout file:passphrase.txt -out server.key 2048
    openssl req -new -passin file:passphrase.txt -key server.key -out server.csr -subj "/C=GB/O=VPN Host/OU=Docker VPN/CN=*.vpn.local" \
    cp server.key server.key.org
    openssl rsa -in server.key.org -passin file:passphrase.txt -out server.key
    openssl x509 -req -days 36500 -in server.csr -signkey server.key -out server.crt

## Client Profile:
* The client profile provides various client sided tweaks and configuration
* /etc/ocserv/client_profile.xml contains the configuration in question
* This can be modified, and is well documented on the Cisco website for the various options.
* It's unlikely that this requires any configuration

## Additional tweaks and changes:
* /etc/ocserv/ocserv.conf is provided for any additional config changes
* Documentation on configuration directives can be found here: https://ocserv.gitlab.io/www/manual.html