## Nim-Libp2p
## Copyright (c) 2018 Status Research & Development GmbH
## Licensed under either of
##  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
##  * MIT license ([LICENSE-MIT](LICENSE-MIT))
## at your option.
## This file may not be copied, modified, or distributed except according to
## those terms.

{.used.}

import unittest, sequtils, options, tables, sets
import chronos
import utils,
       ../../libp2p/[errors,
                     switch,
                     connection,
                     stream/bufferstream,
                     crypto/crypto,
                     protocols/pubsub/pubsub,
                     protocols/pubsub/floodsub,
                     protocols/pubsub/rpc/messages,
                     protocols/pubsub/rpc/message]

import ../helpers

proc waitSub(sender, receiver: auto; key: string) {.async, gcsafe.} =
  # turn things deterministic
  # this is for testing purposes only
  var ceil = 15
  let fsub = cast[FloodSub](sender.pubSub.get())
  while not fsub.floodsub.hasKey(key) or
        not fsub.floodsub[key].contains(receiver.peerInfo.id):
    await sleepAsync(100.millis)
    dec ceil
    doAssert(ceil > 0, "waitSub timeout!")

suite "FloodSub":
  teardown:
    for tracker in testTrackers():
      check tracker.isLeaked() == false

  test "FloodSub basic publish/subscribe A -> B":
    proc runTests(): Future[bool] {.async.} =
      var completionFut = newFuture[bool]()
      proc handler(topic: string, data: seq[byte]) {.async, gcsafe.} =
        check topic == "foobar"
        completionFut.complete(true)

      let
        nodes = generateNodes(2)
        nodesFut = await allFinished(
          nodes[0].start(),
          nodes[1].start()
        )

      await subscribeNodes(nodes)

      await nodes[1].subscribe("foobar", handler)
      await waitSub(nodes[0], nodes[1], "foobar")

      await nodes[0].publish("foobar", cast[seq[byte]]("Hello!"))

      result = await completionFut.wait(5.seconds)

      await allFuturesThrowing(
        nodes[0].stop(),
        nodes[1].stop()
      )

      for fut in nodesFut:
        let res = fut.read()
        await allFuturesThrowing(res)
    check:
      waitFor(runTests()) == true

  test "FloodSub basic publish/subscribe B -> A":
    proc runTests(): Future[bool] {.async.} =
      var completionFut = newFuture[bool]()
      proc handler(topic: string, data: seq[byte]) {.async, gcsafe.} =
        check topic == "foobar"
        completionFut.complete(true)

      var nodes = generateNodes(2)
      var awaiters: seq[Future[void]]
      awaiters.add((await nodes[0].start()))
      awaiters.add((await nodes[1].start()))

      await subscribeNodes(nodes)

      await nodes[0].subscribe("foobar", handler)
      await waitSub(nodes[1], nodes[0], "foobar")

      await nodes[1].publish("foobar", cast[seq[byte]]("Hello!"))

      result = await completionFut.wait(5.seconds)

      await allFuturesThrowing(nodes[0].stop(), nodes[1].stop())
      await allFuturesThrowing(awaiters)

    check:
      waitFor(runTests()) == true

  test "FloodSub validation should succeed":
    proc runTests(): Future[bool] {.async.} =
      var handlerFut = newFuture[bool]()
      proc handler(topic: string, data: seq[byte]) {.async, gcsafe.} =
        check topic == "foobar"
        handlerFut.complete(true)

      var nodes = generateNodes(2)
      var awaiters: seq[Future[void]]
      awaiters.add((await nodes[0].start()))
      awaiters.add((await nodes[1].start()))

      await subscribeNodes(nodes)
      await nodes[1].subscribe("foobar", handler)
      await waitSub(nodes[0], nodes[1], "foobar")

      var validatorFut = newFuture[bool]()
      proc validator(topic: string,
                     message: Message): Future[bool] {.async.} =
        check topic == "foobar"
        validatorFut.complete(true)
        result = true

      nodes[1].addValidator("foobar", validator)

      await nodes[0].publish("foobar", cast[seq[byte]]("Hello!"))

      await allFuturesThrowing(handlerFut, handlerFut)
      await allFuturesThrowing(nodes[0].stop(), nodes[1].stop())
      await allFuturesThrowing(awaiters)
      result = true

    check:
      waitFor(runTests()) == true

  test "FloodSub validation should fail":
    proc runTests(): Future[bool] {.async.} =
      proc handler(topic: string, data: seq[byte]) {.async, gcsafe.} =
        check false # if we get here, it should fail

      var nodes = generateNodes(2)
      var awaiters: seq[Future[void]]
      awaiters.add((await nodes[0].start()))
      awaiters.add((await nodes[1].start()))

      await subscribeNodes(nodes)
      await nodes[1].subscribe("foobar", handler)
      await waitSub(nodes[0], nodes[1], "foobar")

      var validatorFut = newFuture[bool]()
      proc validator(topic: string,
                     message: Message): Future[bool] {.async.} =
        validatorFut.complete(true)
        result = false

      nodes[1].addValidator("foobar", validator)

      await nodes[0].publish("foobar", cast[seq[byte]]("Hello!"))

      await allFuturesThrowing(nodes[0].stop(), nodes[1].stop())
      await allFuturesThrowing(awaiters)
      result = true

    check:
      waitFor(runTests()) == true

  test "FloodSub validation one fails and one succeeds":
    proc runTests(): Future[bool] {.async.} =
      var handlerFut = newFuture[bool]()
      proc handler(topic: string, data: seq[byte]) {.async, gcsafe.} =
        check topic == "foo"
        handlerFut.complete(true)

      var nodes = generateNodes(2)
      var awaiters: seq[Future[void]]
      awaiters.add((await nodes[0].start()))
      awaiters.add((await nodes[1].start()))

      await subscribeNodes(nodes)
      await nodes[1].subscribe("foo", handler)
      await waitSub(nodes[0], nodes[1], "foo")
      await nodes[1].subscribe("bar", handler)
      await waitSub(nodes[0], nodes[1], "bar")

      proc validator(topic: string,
                     message: Message): Future[bool] {.async.} =
        if topic == "foo":
          result = true
        else:
          result = false

      nodes[1].addValidator("foo", "bar", validator)

      await nodes[0].publish("foo", cast[seq[byte]]("Hello!"))
      await nodes[0].publish("bar", cast[seq[byte]]("Hello!"))

      await allFuturesThrowing(nodes[0].stop(), nodes[1].stop())
      await allFuturesThrowing(awaiters)
      result = true

    check:
      waitFor(runTests()) == true

  test "FloodSub multiple peers, no self trigger":
    proc runTests(): Future[bool] {.async.} =
      var passed = 0

      var futs = newSeq[(Future[void], TopicHandler, ref int)](10)
      for i in 0..<10:
        closureScope:
          var
            fut = newFuture[void]()
            counter = new int
          futs[i] = (
            fut,
            (proc(topic: string, data: seq[byte]) {.async, gcsafe.} =
              check topic == "foobar"
              inc counter[]
              if counter[] == 9:
                fut.complete()),
            counter
          )

      var nodes: seq[Switch] = newSeq[Switch]()
      for i in 0..<10:
        nodes.add newStandardSwitch()


      var awaitters: seq[Future[void]]
      for i in 0..<10:
        awaitters.add(await nodes[i].start())

      await subscribeNodes(nodes)

      for i in 0..<10:
        await nodes[i].subscribe("foobar", futs[i][1])

      var subs: seq[Future[void]]
      for i in 0..<10:
        for y in 0..<10:
          if y != i:
            subs &= waitSub(nodes[i], nodes[y], "foobar")
      await allFuturesThrowing(subs)

      var pubs: seq[Future[void]]
      for i in 0..<10:
        pubs &= nodes[i].publish("foobar", cast[seq[byte]]("Hello!"))
      await allFuturesThrowing(pubs)

      await allFuturesThrowing(futs.mapIt(it[0]))
      await allFuturesThrowing(nodes.mapIt(it.stop()))
      await allFuturesThrowing(awaitters)

      result = true
    check:
      waitFor(runTests()) == true

  test "FloodSub multiple peers, with self trigger":
    proc runTests(): Future[bool] {.async.} =
      var passed = 0

      var futs = newSeq[(Future[void], TopicHandler, ref int)](10)
      for i in 0..<10:
        closureScope:
          var
            fut = newFuture[void]()
            counter = new int
          futs[i] = (
            fut,
            (proc(topic: string, data: seq[byte]) {.async, gcsafe.} =
              check topic == "foobar"
              inc counter[]
              if counter[] == 10:
                fut.complete()),
            counter
          )

      var nodes: seq[Switch] = newSeq[Switch]()
      for i in 0..<10:
        nodes.add newStandardSwitch(triggerSelf = true)


      var awaitters: seq[Future[void]]
      for i in 0..<10:
        awaitters.add(await nodes[i].start())

      await subscribeNodes(nodes)

      for i in 0..<10:
        await nodes[i].subscribe("foobar", futs[i][1])

      var subs: seq[Future[void]]
      for i in 0..<10:
        for y in 0..<10:
          if y != i:
            subs &= waitSub(nodes[i], nodes[y], "foobar")
      await allFuturesThrowing(subs)

      var pubs: seq[Future[void]]
      for i in 0..<10:
        pubs &= nodes[i].publish("foobar", cast[seq[byte]]("Hello!"))
      await allFuturesThrowing(pubs)

      await allFuturesThrowing(futs.mapIt(it[0]))
      await allFuturesThrowing(nodes.mapIt(it.stop()))
      await allFuturesThrowing(awaitters)

      result = true
    check:
      waitFor(runTests()) == true
