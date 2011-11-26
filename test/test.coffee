
assert = require "assert"


describe "testing test",  ->
  it "should pass", (done) ->
    setTimeout ->
      assert.equal 1, 1
      done()
    , 1000

  # it "should fail", (done) ->
  #   setTimeout ->
  #     assert.equal 1, 2
  #     done()
  #   , 1000

  it "should sync pass", ->
    assert.equal 1, 1

