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
