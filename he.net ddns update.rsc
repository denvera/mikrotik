# Update Hurricane Electric DDNS IPv4 address
# 
# Taken from http://wiki.mikrotik.com/wiki/Dynamic_DNS_Update_Script_for_Hurricane_Electric_DNS
# Updated to only send update when IP changes from last recorded value
#
# ddnshost: Your he.net dynamic dns hostname
# key: Key generated for your dyn dns record
# WANinterface: Interface to get IP from (eg: pppoe-whatever)

:local ddnshost "your.domain.name"
:local key "your-generated-dns-key"
:local updatehost "dyn.dns.he.net"
:local WANinterface "your-interface-name"
:local outputfile ("HE_DDNS" . ".txt")

# Internal processing below...
# ----------------------------------
:global old4addr
:local ipv4addr

# Get WAN interface IP address
:set ipv4addr [/ip address get [/ip address find interface=$WANinterface] address]
:set ipv4addr [:pick [:tostr $ipv4addr] 0 [:find [:tostr $ipv4addr] "/"]]

:if ([:len $ipv4addr] = 0) do={
   :log error ("Could not get IP for interface " . $WANinterface)
   :error ("Could not get IP for interface " . $WANinterface)
}

:if ([:typeof $old4addr] = "nothing" || $old4addr != $ipv4addr) do={
  :log warning ("Updating DDNS IPv4 address" . " Client IPv4 address to new IP " . $ipv4addr . "...")
  /tool fetch url="http://$ddnshost:$key@$updatehost/nic/update?hostname=$ddnshost&myip=$ipv4addr" dst-path=$outputfile
  :log warning ([/file get ($outputfile) contents])
  /file remove ($outputfile)
  :global old4addr $ipv4addr
} else={
#  :log warning "[he.net] No changes needed"
}