#!/bin/sh

MARK="${MARK:-0x1000}"
USER="${USER:-hysteria}"
PORT="${PORT:-2500}"
TABLE="${TABLE:-hysteria}"
SET="${SET:-proxy}"
ROUTE_TABLE="${ROUTE_TABLE:-100}"

setup_route_table() {
	ip route add local default dev lo table $ROUTE_TABLE
	ip rule add fwmark $MARK/$MARK lookup $ROUTE_TABLE
}

setdown_route_table() {
	while ip rule del lookup $ROUTE_TABLE; do
		:
	done >/dev/null 2>&1
	ip route flush table $ROUTE_TABLE
}

show_route_table() {
	ip rule show | grep "lookup $ROUTE_TABLE"
	ip route show table $ROUTE_TABLE
}

setup_nft() {
	nft -f - <<-EOF
		define L4PROTO={ tcp, udp }
		define BYPASS={
			0.0.0.0/8, 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16,
			172.16.0.0/12, 192.168.0.0/16, 224.0.0.0/3
		}

		table ip $TABLE {
			set $SET {
				typeof ip daddr
			}

			chain prerouting {
				type filter hook prerouting priority mangle; policy accept;

				# Bypass traffic already taken over by TProxy
				iifname lo socket transparent 1 accept

				# Locally rerouted packets are sent to the tproxy port
				iifname lo mark $MARK meta l4proto \$L4PROTO counter tproxy to :$PORT accept

				# Bypass Private and Special IP Addresses
				ip daddr \$BYPASS counter return

				# Send selected traffic to tproxy port
				ip daddr @$SET meta l4proto \$L4PROTO counter tproxy to :$PORT meta mark set $MARK accept
			}

			chain output {
				type route hook output priority mangle; policy accept;

				# Bypass traffic for specific users, used to pass traffic generated by hysteria itself
				meta skuid $USER return

				# Bypass Private and Special IP Addresses
				ip daddr \$BYPASS return

				# Set a mark for selected traffic to trigger rerouting
				ip daddr @$SET meta l4proto \$L4PROTO meta mark set $MARK
			}
		}
	EOF
}

setdown_nft() {
	nft delete table ip $TABLE >/dev/null 2>&1
}

show_nft() {
	nft list table ip $TABLE
}

up() {
	setup_route_table
	setup_nft
}

down() {
	setdown_route_table
	setdown_nft
}

show() {
	show_route_table
	show_nft
}

cmd=""
[ $# -ge 1 ] && {
	cmd=$1
	shift
}

case "$cmd" in
	up|down)
		$cmd $@
		;;
	*)
		show
		;;
esac
