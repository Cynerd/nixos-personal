final: _: let
  inherit (final) pow foldl genList id reverseList bitAnd pow2 length add zipListsWith;
in {
  # Generic power of number
  pow = base: e:
    if e == 0
    then 1
    else foldl (x: _: x * base) 1 (genList id (e - 1));
  # Power of 2
  pow2 = pow 2;

  # Convert integer to list of bits
  int2bits = len: e: reverseList (genList (x: bitAnd e (pow2 (x + 1)) > 0) len);
  # Reverse operation for int2bits
  bits2int = l: let
    len = length l;
    zf = a: b:
      if a
      then pow2 b
      else 0;
  in
    foldl add 0 (zipListsWith zf l (genList (i: len - i) len));

  # IPv4 utilities
  ipv4 = import ./ipv4.nix final;
}
