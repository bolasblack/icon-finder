
'use strict'

describe 'lib specs', ->
  describe 'chai', ->
    it 'should have expect function', ->
      throw Error('Chai expect not exist') unless expect?
      expect(1).to.equal 1

    it 'should have assert object', ->
      throw Error('Chai assert not exist') unless assert?
      assert.ok true, 'Chai assert not work'

    it 'should support should style', ->
      throw Error('Chai should not exist') unless should?
      throw Error('obj.should not exist') unless {}.should?
      1.should.equal 1

  describe 'sinon', ->
    it 'should work', ->
      a = fn: sinon.spy()
      a.fn()
      a.fn.should.be.called

