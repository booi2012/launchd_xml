#!/bin/sh
#
# Configure routing and miscellaneous network tunables
#
# Removed dependency from /etc/rc.

routing_start()
{
	static_start
	options_start
}

routing_stop()
{
	route -n flush
}

static_start()
{
	case ${defaultrouter} in
	[Nn][Oo] | '')
		;;
	*)
		static_routes="default ${static_routes}"
		route_default="default ${defaultrouter}"
		;;
	esac

	# Setup static routes. This should be done before router discovery.
	#
	if [ -n "${static_routes}" ]; then
		for i in ${static_routes}; do
			eval route_args=\$route_${i}
			route add ${route_args}
		done
	fi
	# Now ATM static routes
	#
	if [ -n "${natm_static_routes}" ]; then
		for i in ${natm_static_routes}; do
			eval route_args=\$route_${i}
			atmconfig natm add ${route_args}
		done
	fi
}

options_start()
{
	echo -n 'Additional routing options:'
	case ${tcp_extensions} in
	[Yy][Ee][Ss] | '')
		;;
	*)
		echo -n ' tcp extensions=NO'
		sysctl net.inet.tcp.rfc1323=0 >/dev/null
		;;
	esac

	case ${icmp_bmcastecho} in
	[Yy][Ee][Ss])
		echo -n ' broadcast ping responses=YES'
		sysctl net.inet.icmp.bmcastecho=1 >/dev/null
		;;
	esac

	case ${icmp_drop_redirect} in
	[Yy][Ee][Ss])
		echo -n ' ignore ICMP redirect=YES'
		sysctl net.inet.icmp.drop_redirect=1 >/dev/null
		;;
	esac

	case ${icmp_log_redirect} in
	[Yy][Ee][Ss])
		echo -n ' log ICMP redirect=YES'
		sysctl net.inet.icmp.log_redirect=1 >/dev/null
		;;
	esac

	case ${gateway_enable} in
	[Yy][Ee][Ss])
		echo -n ' IP gateway=YES'
		sysctl net.inet.ip.forwarding=1 >/dev/null
		;;
	esac

	case ${forward_sourceroute} in
	[Yy][Ee][Ss])
		echo -n ' do source routing=YES'
		sysctl net.inet.ip.sourceroute=1 >/dev/null
		;;
	esac

	case ${accept_sourceroute} in
	[Yy][Ee][Ss])
		echo -n ' accept source routing=YES'
		sysctl net.inet.ip.accept_sourceroute=1 >/dev/null
		;;
	esac

	case ${tcp_keepalive} in
	[Nn][Oo])
		echo -n ' TCP keepalive=NO'
		sysctl net.inet.tcp.always_keepalive=0 >/dev/null
		;;
	esac

	case ${tcp_drop_synfin} in
	[Yy][Ee][Ss])
		echo -n ' drop SYN+FIN packets=YES'
		sysctl net.inet.tcp.drop_synfin=1 >/dev/null
		;;
	esac

	case ${ipxgateway_enable} in
	[Yy][Ee][Ss])
		echo -n ' IPX gateway=YES'
		sysctl net.ipx.ipx.ipxforwarding=1 >/dev/null
		;;
	esac

	case ${arpproxy_all} in
	[Yy][Ee][Ss])
		echo -n ' ARP proxyall=YES'
		sysctl net.link.ether.inet.proxyall=1 >/dev/null
		;;
	esac

	case ${ip_portrange_first} in
	[Nn][Oo] | '')
		;;
	*)
		echo -n " ip_portrange_first=$ip_portrange_first"
		sysctl net.inet.ip.portrange.first=$ip_portrange_first >/dev/null
		;;
	esac

	case ${ip_portrange_last} in
	[Nn][Oo] | '')
		;;
	*)
		echo -n " ip_portrange_last=$ip_portrange_last"
		sysctl net.inet.ip.portrange.last=$ip_portrange_last >/dev/null
		;;
	esac

	echo '.'
}

# start here
# used to emulate "requires/provide" functionality
pidfile="/var/run/routing.pid"
touch $pidfile
routing_start
exit 0
