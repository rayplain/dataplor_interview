# DataPlor Challenge

This project is a solution to a coding challenge designed to test decision making and code organization skills. The project involves creating an API with two endpoints that interact with a tree of nodes and a model of birds.

## Project Description

The project uses an adjacency list to create a tree of nodes where a child's `parent_id` equals a parent's `id`. The tree is used to find the lowest common ancestor of two nodes and the depth of the tree from the root to the lowest common ancestor.

The project also involves a second model, `birds`. Nodes have many birds and birds belong to nodes. The second endpoint takes an array of node ids and returns the ids of the birds that belong to one of those nodes or any descendant nodes.

## API Endpoints

1. `/common_ancestor`: Takes two parameters, `a` and `b`, and returns the `root_id`, `lowest_common_ancestor_id`, and `depth` of the tree of the lowest common ancestor that those two node ids share.

2. `/birds`: Takes an array of node ids and returns the ids of the birds that belong to one of those nodes or any descendant nodes.

## Outside of Scope
I left a few things out of the scope that would most certainly be done in a real world project. This things include:

1. Any sort of security at all
2. Any sort of real database optimizations.
   1. One of the assumptions of the task was to think about how data grows and how our solution would work. I did choose a naive solution for this in the hopes that other solutions could be discussed during the interview when I could ask more questions and gather more data. This solution, being naive, would at least prevent inaccurate abstractions in a real world situation
3. Only modest structure and organization.
4. Some basic YARDoc style comments incase we wanted to run a yard server.
5. Any sort of error handling at all and few guard clauses.


## Thoughts and Areas of interest
I created query objects for any complex arel queries. I much prefer Arel to any sort of raw SQL but it can be wordy and definitely needed to be abstracted. Im a decent fan of query objects but

I prefer to call them from their models if at all possible, or at the very least, keep reads consistent and in one location, writes perhaps with service objects in another location. Preferably out of models.

most of the heavy lifting will be done in the queries folder

As mentioned I chose a naive approach to the raw data thinking that I could discuss possible solutions after getting to ask questions. Sort of like a how would we improve this sort of thing that I vcould demonstrate in an interview. Because I worked on raw data that limited the amount of "railsy" ways to do certain things like has_many's and things like that. 
Preprossed data like maybe a ltree path field or materialized views could work but I wouwld love to discuss that in an interview after asking more questions about the nature of the data and how it grows. 

## Usage
This is a rails 7 application in Ruby 3.2.2 so standard issue install applies.

I did include seed data which includes the CSV I was provided as well as a random selection of generated and randomly assigned birds for testing.

After running the server with rails server I included the endpoints for birds and common ancestor as seen in the routes.rb file.

Testing is done with rspec and factory bot