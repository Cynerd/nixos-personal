#!/usr/bin/env bash
# Generate access tokens for InfluxDB to submit monitoring and other
# telemetries.
set -eu

cd "${0%/*}/.."

influx_args=(
	# Warning: you might want to modify this when you move the InfluxDB host
	"--host" "http://ridcully:8086"
	"--token" "$(pass 'nixos-secrets/influxdb/token/cynerd')"
)


monitoring_enabled() {
	local hostname="$1"
	[ "$(nix eval ".#nixosConfigurations.$hostname.config.cynerd.monitoring.enable")" = "true" ]
}

token_is_valid() {
	[ "$(influx auth list "${influx_args[@]}" --json | jq "map(.token) | any(. == \"$1\")")" = "true" ]
}

ensure_token() {
	local hostname="$1"
	local token
	pass_path="nixos-secrets/influxdb/token/$hostname"
	if ! token="$(pass "$pass_path" 2>/dev/null)" \
		|| ! token_is_valid "$token"; then
			influx auth create -d "monitoring-$hostname" --write-buckets --json \
				| jq -r '.token' \
				| sed 's/^\(.*\)$/\1\n\1/' \
				| pass insert -f "$pass_path"
	fi
}

nix eval --json --apply 'builtins.attrNames' .#nixosConfigurations \
	| jq -r '.[]' \
	| while read -r hostname; do
		if monitoring_enabled "$hostname"; then
			ensure_token "$hostname"
		fi
	done;
