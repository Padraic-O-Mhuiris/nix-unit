{ mkTest, mkTests, describe }:
let
  arbitraryNixExpr = {
    some = {
      random = { state = 2; };
      other = { random = { state = 2; }; };
    };
  };

  testExpr = {
    x = 2;
    y = { z = 3; };
  };
in {

  my-test = mkTest testExpr ({ it }: [

    (describe "x" ({ x }: x)
      ({ it }: [ (it "x should be equal to 2" ({ equals, ... }: equals 2)) ]))

    (describe "y" ({ y }: y) ({ it }:
      [
        (it "y should be equal to name value pair of z and 3"
          ({ equals, ... }: equals { z = 3; }))
      ]))
  ]);

  # describe "Arbitrary Nix Expr" arbitraryNixExpr
  # ({ describe, it }:
  #   [
  #     (it ''should have "some" as a key in expr'' (has.key "some"))
  #     # (describe "under random in expr" (expr: expr.random) ({ it, ... }:
  #     #   [
  #     #     (it
  #     #       "should be an attrset with an entry named state containing a value of 2"
  #     #       (has.value { state = 2; }))
  #     #   ]))
  #     # (describe "under other in expr" ({ other }: other) ({ describe, ... }:
  #     #   [
  #     #     (describe "under random in expr" ({ random }: random)
  #     #       ({ describe, ... }: [ ]))
  #     #   ]))
  #   ]);
}
