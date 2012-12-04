test("this should pass", function() {
  ok(true, "Passed!");
});

test("this should fail", function() {
  ok(false, "This should fail");
});

test("error test", function() {
  foobar();
});

test("expectation test", function() {
  expect(1);
});

test("console logs", function() {
  expect(0);
  console.log("Oh hai!")
});
