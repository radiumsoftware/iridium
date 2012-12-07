describe("A suite", function() {
  it("contains spec with an expectation", function() {
    expect(true).toBe(true);
  });

  it("can have a failing expecation", function() {
    expect(false).toBe(true);
  });

  it("can have failures", function() {
    fooBar();
  });

  describe("A nested suite", function() {
    it("can fail", function() {
      expect(false).toBe(true);
    });
  });
});
