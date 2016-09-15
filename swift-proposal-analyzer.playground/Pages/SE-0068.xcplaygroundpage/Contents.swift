/*:
# Expanding Swift `Self` to class members and value types

* Proposal: [SE-0068](0068-universal-self.md)
* Author: [Erica Sadun](http://github.com/erica)
* Review Manager: [Chris Lattner](http://github.com/lattner)
* Status: **Accepted with revisions**
* Decision Notes: [Rationale](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160425/015977.html)
* Bug: [SR-1340](https://bugs.swift.org/browse/SR-1340)
* Previous Revisions: [1](https://github.com/apple/swift-evolution/blob/bcd77b028cb2fc9f07472532b120e927c7e48b34/proposals/0068-universal-self.md), [2](https://github.com/apple/swift-evolution/blob/13d9771e86c5639b8320f05e5daa31a62bac0f07/proposals/0068-universal-self.md)

## Introduction

Within a class scope, `Self` means "the dynamic class of `self`". This proposal extends that courtesy to value types and to the bodies of class members
by renaming `dynamicType` to `Self`. This establishes a universal and consistent
way to refer to the dynamic type of the current receiver. 


*This proposal was discussed on the Swift Evolution list in the [\[Pitch\] Adding a Self type name shortcut for static member access](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160404/014132.html) thread.*

## Motivation

It is common in Swift to reference an instance's type, whether accessing 
a static member or passing types for unsafe bitcasts, among other uses.
You can either specify a type by its full name or use `self.dynamicType`
to access an instance's dynamic runtime type as a value. 

```
struct MyStruct {
    static func staticMethod() { ... }
    func instanceMethod() {
        MyStruct.staticMethod()
        self.dynamicType.staticMethod()
    }
}
```

Introducing `Self` addresses the following issues:

* `dynamicType` remains an exception to Swift's lowercased keywords rule. This change eliminates a special case that's out of step with Swift's new standards.
* `Self` is shorter and clearer in its intent. It mirrors `self`, which refers to the current instance.
* It provides an easier way to access static members. As type names grow large, readability suffers. `MyExtremelyLargeTypeName.staticMember` is unwieldy to type and read.
* Code using hardwired type names is less portable than code that automatically knows its type.
* Renaming a type means updating any `TypeName` references in code.
* Using `self.dynamicType` fights against Swift's goals of concision and clarity in that it is both noisy and esoteric.

Note that `self.dynamicType.classMember` and `TypeName.classMember` may not be synonyms in class types with non-final members.

## Detail Design

This proposal introduces `Self`, which equates to and replaces `self.dynamicType`. 
You will continue to specify full type names for any other use. Joe Groff writes, "I don't think it's all that onerous to have  to write `ClassName.foo` if that's really what you specifically mean."

## Alternatives Considered

Not at this time

## Acknowlegements

Thanks Sean Heber, Kevin Ballard, Joe Groff, Timothy Wood, Brent Royal-Gordon, Andrey Tarantsov, Austin Zheng

## Rationale

On [April 27, 2016](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160425/015977.html), the core team decided to **accept a subset of** this proposal.

> This proposal had light discussion in the community review process, but the core team heavily debated it.  It includes two pieces:
> 
> 1. Expanding the existing support for Self to work in value types, and in the bodies of classes.
> 
> 2. Replacing the x.dynamicType expression with x.Self, a purely syntactic change that eliminates the “dynamicType” keyword.
> 
> The core team has accepted the first half for this proposal.  This allows the use of “Self” as shorthand for referring to the containing type (in the case of structs, enums, and final class) or the dynamic type (in the case of non-final classes).  Most of the discussion in the core team centered around whether people familiar with the former behavior would be surprised by the (more general) behavior when using it in a class, but they came to agree that this is actually a simple and general model, and a helpful point of consistency.
> 
> In contrast, there are still a number of concerns with rebranding x.dynamicType as x.Self.  This may (or may not) be the right ultimate direction to go, but it should be split out of this proposal.  There is another outstanding proposal that would eliminate the “Type.self” syntax as being necessary, and the core team would like to resolve that discussion before tackling x.dynamicType.


----------

[Previous](@previous) | [Next](@next)
*/
