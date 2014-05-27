# Tested with RouterOS 6.12
:global lastbackup
:local emailaddress "your@email.com"
:local sysname [/system identity get name]
:local outfile ($sysname . "-" . ([:pick [/system clock get date] 4 6] . "-" . [:pick [/system clock get date] 0 3] . "-" . [:pick [/system clock get date] 7 11]))

:if ([:typeof $lastbackup] != "nothing" && $lastbackup != ($outfile . ".rsc")) do={
  :if ([:len [/file find name=$lastbackup]] > 0) do={ 
    :log warning "Removing $lastbackup"
    /file remove $lastbackup
  }
}

/export file=$outfile compact
/tool e-mail send subject="$outfile daily backup" file=($outfile . ".rsc") to="$emailaddress"
:log warning "Sent daily backup $outfile"
:global lastbackup ($outfile . ".rsc")