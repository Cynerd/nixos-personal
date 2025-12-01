lib: let
  inherit (lib) int2bits toInt splitString flatten bits2int sublist genList zipListsWith;
  inherit (lib.ipv4) ip2bits bits2ip netmaskBits int2ip ip2int prefix2ip;
in {
  # Converts string representation of IPv4 address to 32 bits
  ip2bits = ip: let
    perBits = map (x: int2bits 8 (toInt x)) (splitString "." ip);
  in
    flatten perBits;
  # Converts 32 bits to IPv4
  bits2ip = bits: let
    bts = i: toString (bits2int (sublist (i * 8) 8 bits));
  in "${bts 0}.${bts 1}.${bts 2}.${bts 3}";

  # Convert IPv4 to number
  ip2int = ip: bits2int (ip2bits ip);
  # Convert number to IPv4
  int2ip = ip: bits2ip (int2bits 32 ip);

  # Generate bits for netmas of gitven prefix length
  netmaskBits = prefixLength: genList (x: x < prefixLength) 32;
  # Convert IP network prefix length to network mask
  prefix2netmask = prefixLength: bits2ip (netmaskBits prefixLength);
  # Mask IP by network mask specified by given network prefix length
  prefix2ip = ip: prefixLength: let
    a = netmaskBits prefixLength;
    b = ip2bits ip;
  in
    bits2ip (zipListsWith (a: b: a && b) a b);
  # Last address in the range
  prefix2broadcast = ip: prefixLength: let
    a = netmaskBits prefixLength;
    b = ip2bits ip;
  in
    bits2ip (zipListsWith (a: b: !a || b) a b);

  # Offset address in network
  ipAdd = ip: prefixLength: off: int2ip ((ip2int (prefix2ip ip prefixLength)) + off);
}
