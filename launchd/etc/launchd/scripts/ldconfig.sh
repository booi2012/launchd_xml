#!/bin/sh
#
# Removed dependency from /etc/rc.

ldconfig_start()
{
	_ins=
	ldconfig=${ldconfig_command}
	# checkyesno ldconfig_insecure && _ins="-i"
	if [ -x "${ldconfig_command}" ]; then
		_LDC="/lib /usr/lib"
		for i in ${ldconfig_local_dirs}; do
			if [ -d "${i}" ]; then
				ldconfig_paths="${ldconfig_paths} `find ${i} -type f`"
			fi
		done
		for i in ${ldconfig_paths} /etc/ld-elf.so.conf; do
			if [ -r "${i}" ]; then
				_LDC="${_LDC} ${i}"
			fi
		done
		echo 'ELF ldconfig path:' ${_LDC}
		${ldconfig} -elf ${_ins} ${_LDC}

		case `sysctl -n hw.machine_arch` in
		amd64)
			for i in ${ldconfig_local32_dirs}; do
				if [ -d "${i}" ]; then
					ldconfig32_paths="${ldconfig32_paths} `find ${i} -type f`"
				fi
			done
			echo '32-bit compatibility ldconfig path:' ${ldconfig32_paths}
			${ldconfig} -32 -m ${_ins} ${ldconfig32_paths}
			;;
		esac

		# Legacy aout support for i386 only
		case `sysctl -n hw.machine_arch` in
		i386)
			# Default the a.out ldconfig path.
			: ${ldconfig_paths_aout=${ldconfig_paths}}
			_LDC=/usr/lib/aout
			for i in ${ldconfig_paths_aout} /etc/ld.so.conf; do
				if [ -r "${i}" ]; then
					_LDC="${_LDC} ${i}"
				fi
			done
			echo 'a.out ldconfig path:' ${_LDC}
			${ldconfig} -aout ${_ins} ${_LDC}
			;;
		esac
	fi
}

# start here
# used to emulate "requires/provide" functionality
pidfile="/var/run/ldconfig.pid"
touch $pidfile
ldconfig_command="/sbin/ldconfig"

ldconfig_start
exit 0
