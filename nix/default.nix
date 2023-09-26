{ lib }:

/* - checkFn is intended as a callback function which could be one of:
   -- has.key - validates that the expr is an attrset containing a key
   -- has.keys - validates that the expr is an attrset containing multiple keys
   -- has.keys - validates that the expr is an attrset containing multiple keys

   Ultimately it should
*/
let

  inherit (lib) nameValuePair;
  inherit (lib.strings) substring;
  inherit (lib.lists) imap0 isList foldr foldl;

  testType = { EQUALS = "EQUALS"; };

  generateTestId = message: entropy:
    let
      idHash =
        substring 0 10 (builtins.hashString "sha256" "${entropy}:${message}");
    in "${entropy}::${idHash}";
in rec {
  treeMap = fn: testMatrix:
    foldl (acc: item:
      if (item.__test__ == "__test_branch__") then
        acc ++ [ (treeMap fn item) ]
      else
        acc ++ [ (fn item) ]) [ ] testMatrix.value;

  countTests = testMatrix:
    foldl (acc: item:
      if (item.__test__ == "__test_branch__") then
        acc + (countTests item)
      else
        acc + 1) 0 testMatrix.value;

  Assertion.equals = left: right: {
    type = testType.EQUALS;
    inherit left right;
    __test__ = "__assertion__";
  };

  # TestCase
  TestCase = message: assertionFunctor: cntr:
    let id = generateTestId message cntr;
    in {
      __test__ = "__test_case__";
      value = assertionFunctor;
      inherit id message;
    };

  TestBlock = message: testMatrix: cntr:
    let id = generateTestId message cntr;
    in {
      __test__ = "__test_branch__";
      inherit id message;
      value =
        imap0 (idx: fn: (fn "${toString cntr}-${toString idx}")) testMatrix;
    };

  Test = message: testMatrix:
    let testTree = (imap0 (idx: fn: fn "${toString idx}") testMatrix);
    in {
      __test__ = "__test_root__";
      value = testTree;
    };

}
