{ lib }:

/* - checkFn is intended as a callback function which could be one of:
   -- has.key - validates that the expr is an attrset containing a key
   -- has.keys - validates that the expr is an attrset containing multiple keys
   -- has.keys - validates that the expr is an attrset containing multiple keys

   Ultimately it should
*/
let

  inherit (lib.strings) substring;
  inherit (lib.lists) imap0 isList foldr;

  testType = { EQUALS = "EQUALS"; };

  generateTestId = message: entropy:
    let
      idHash =
        substring 0 10 (builtins.hashString "sha256" "${entropy}:${message}");
    in "${entropy}::${idHash}::${message}";

  checkFunctions = {
    equals = expression: message: value: {
      __test__ = "__test_leaf__";
      type = testType.EQUALS;
      id = generateTestId message;
      left = value;
      right = expression;
      inherit message;
    };
    # isTrue = message: value: expression: {
    #   __test_type__ = "__test_true__";
    #   left = value;
    #   right = true;
    # };
    # isFalse = message: value: expression: {
    #   __test_type__ = "__test_false__";
    #   left = value;
    #   right = false;
    # };
  };

in rec {
  # matrixMap = fn: list:
  #   map (item: if isList item then matrixMap fn item else fn item) list;

  treeMap = node:
    if (isList node) then
      map (item: treeMap item) node
    else
      (if node.__test__ == "__test_branch__" then {
        name = node.id;
        value = (treeMap node.value);
      } else {
        name = node.id;
        value = { inherit (node) type left right; };
      });

  # map (item:
  #   if (isList item) then
  #     treeMap item
  #   else
  #     (if (item.__test__ == "__test_branch__") then
  #       treeMap item.value
  #     else
  #       item.id)) tree;

  mkTest = expression: message: testFunctor:
    let
      testTree = imap0 (idx: fn: fn expression "${toString idx}") (testFunctor {
        test = message: exprFunctor: expression: cntr:
          exprFunctor {
            is.equal.to = value: expression: {
              __test__ = "__test_leaf__";
              type = testType.EQUALS;
              id = generateTestId message cntr;
              left = value;
              right = expression;
              inherit message;
            };
          } expression;

        refine = message: refineFunction: refineFunctor: expression: cntr:
          imap0 (idx: fn: {
            __test__ = "__test_branch__";
            id = generateTestId message cntr;
            inherit message;
            value = let
              refinedTestList = (fn (refineFunction expression)
                "${toString cntr}-${toString idx}");
            in refinedTestList;
          }) refineFunctor;
      });

    in treeMap testTree;

  #    // {
  #   __test__ = "__test_root__";
  # };
}
