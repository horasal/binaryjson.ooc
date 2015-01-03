BinaryJson
==============

An ooc implemention of KLab's Binary JSON.

## Introduction

The original description can be found at KLab's game engine [PlaygroundOSS](https://github.com/KLab/PlaygroundOSS). This engine hasn't been updated for a while but almost everything is still being used in KLab's game, such as [school idol festival](https://play.google.com/store/apps/details?id=klb.android.lovelive).

## Feature

* Compact
* Simple(only 500 lines)
* No Dependency(only use ooc/sdk)
* Fast

## Description

Everyting(Int, String, Object...) is a **JsonNode**. You can get its value through **JsonNode get**.
By **JsonNode toString**, json node can be translated to a normal json file.
Even though JsonNode provides addVal and addKey, they only work for Object and Array.

To modify the content of a JsonNode, access **data** directly. (Will be updated in future)

To parse a binary-json, use class **BJson**. BJson will parse a binary-json file into JsonNode, and
save results in **BJson root**. Notice that root is a JsonArray. It means if your json file is a single-object,
you should use **BJson root data[0]**.

## Usage
Currently it only accepts BinarySequenceReader

Convert a binary-json in memory to text: 

    fw := FileWriter new(args[1])
	br := BinarySequenceReader new(BufferReader new(Buffer new(buf, buflength)))
	// choose file endianness
	// br endianness = ENDIANNESS big 
	json := BJson new(br)
	fw write(json root toString())
	fw close()


## TODO

* Better get (Use Cell<T>?)
* More tests
* Add get ~index and operator overload for array/object
* endianness safe
* more error check
