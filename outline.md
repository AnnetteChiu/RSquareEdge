Outline for RSquareEdge

In someways these topics are borrowed from the outlines for three of the  [datacamp.com](datacamp.com) courses on R. That seems doable in 5 hours.


# Numbers and Data Types

A relatively brief overview of different types of data that can arise.

## Math analogy

Develop an analogy to the different types of numbers used in elementary mathematics: integers, rationals, real numbers, comples

## Numbers

Discuss R's handling of basic numbers


## Logical data

Discuss what logical values are (their use is in subsetting mostly)

## Date and Time data

Discuss how R deals with date data


## Character data

Discuss some string related concepts

## Factors

Explain advantages to a separate type to hold categorical values, as opposed to character data.


## Coercion of one type into another

`as.character`, `as.numeric`, ...



# Data Containers

In R the difference between a (scalar) number and a vector is nothing (as there are no scalar values), but by presenting vectors as a container, we can naturally introduce other containers.

## Vectors

What is a vector

### Vector attributes, Names

Attributes of vectors including 

### Basic indexing

Using  `[]` to access a value in a vector

### `length`, `names`, `names<-`

Common functions that summarize or manipulate vectors. 

Discussion of `<-` type functions

### "vectorized" operations

Discuss how vectorization helps numeric operations

### Why is vectorized good for R users?

Bried discussion of difference in speed between for loops and vectorization.

## Matrices and Arrays

Discussion of reshaped vectors

Introduction of `[,]`

`rownames`, `colnames`

### Tables

A (somewhat) natural example of a matrix

## Lists

Generalized vectors

## DataFrames

A list and a matrix. Fundamental storage concept in R


### Creating data frames

`data.frame` constructor
`read.csv`, `read.table`, ...
from a spreadsheet


### Factors

Manipulating factors

#### Functions related to factors 

## Trees

Brief example of data that doesn't fit into data frame (a webpage is heirarchical)


# Manipulating Data Containers

Go over some of the basic concepts related to subsetting, filtering and aggregation.

## Subsetting, Filtering of vectors

Introduction of logical statements to create indices to filter with

Emphasize the `[,]` notation for subsetting and filtering

## Subsetting, Filtering data frames using `dplyr`

### External packages in R versus base R

Install `dplyr`, discuss other useful packages

### functions

Just the basics on how to use `function(x)`

### Higher-order programming

Using a function as an argument

### The basic apply operations

Do some tasks with data frames using base R commands

### Using `dplyr`

Show how `dplyr` functions can simplify these tasks



