

#get OS name
_my_os="$(uname)"
 
#create an alias based on OS
case $_my_os in
   Linux) alias foo='/path/to/linux/bin/foo' ;;
   FreeBSD|OpenBSD) alias foo='/path/to/bsd/bin/foo' ;;
   SunOS) alias foo='/path/to/sunos/bin/foo' ;;
   *) ;;
esac
