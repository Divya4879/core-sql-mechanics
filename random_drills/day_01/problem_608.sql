/* =====================================================================================
   LEETCODE 608: Tree Node
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Adjacency List Node Classification & Conditional Topology Mapping (`CASE WHEN`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      In relational databases, hierarchical trees are most commonly stored using the 
      "Adjacency List Model", where every row represents a node containing its own identifier 
      (`id`) and a pointer to its parent (`p_id`). 
      
      To classify every node into its correct category (Root, Leaf, or Inner), we evaluate 
      its topological position using conditional logic (`CASE WHEN`):
      - Root Node: Defined entirely by its lack of an ancestor (`p_id IS NULL`).
      - Leaf Node: Defined by having a parent (`p_id IS NOT NULL`), but possessing NO children 
        (its `id` never appears anywhere as another row's `p_id`).
      - Inner Node: The fallback condition—it has a parent *and* it acts as a parent to others.

   -------------------------------------------------------------------------------------
   CRASH COURSE: TREES & HIERARCHIES IN SQL (THE ADJACENCY LIST MODEL)
   -------------------------------------------------------------------------------------
   When querying hierarchical data in flat relational tables, understanding node degrees 
   (incoming parents vs. outgoing children) is critical:
   
   +-----------------+----------------------------------+-------------------------------------------------+
   | Node Type       | Topological Definition           | SQL Detection Strategy                          |
   +-----------------+----------------------------------+-------------------------------------------------+
   | Root            | Top-most node; zero parents      | p_id IS NULL                                    |
   | Leaf            | Bottom-most node; zero children  | id NOT IN (SELECT p_id FROM Tree WHERE ...)     |
   | Inner (Branch)  | Middle node; has parent & child  | Fallback (ELSE 'Inner')                         |
   +-----------------+----------------------------------+-------------------------------------------------+

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How is the hierarchy structured?" 
        (If it's `id` and `p_id`, it's an Adjacency List. Think about parent pointers vs. child lookups).
      - Question B: "How do I check if a node has children?" 
        Check if its `id` appears inside the `p_id` column of the table. If it does, it's a parent/inner node. 
        If it doesn't, it's a leaf node.
      - Question C: "Why must I filter `WHERE p_id IS NOT NULL` in subqueries with `NOT IN`?" 
        Crucial SQL Gotcha: If a subquery used with `NOT IN` evaluates to any `NULL` value, 
        the entire `NOT IN` condition fails and returns zero rows! Always filter out `NULL` 
        when doing existence checks.

   4. COMMON PITFALLS TO AVOID:
      - Using `NOT IN` without filtering `NULL`s in the subquery (causes silent query failure).
      - Forgetting that the order of `WHEN` clauses in a `CASE` statement matters: SQL evaluates 
        them top-to-bottom and stops at the first matching condition.
   ===================================================================================== */

SELECT 
    id,
    CASE 
        -- Rule 1: If there is no parent, it's the root node at the top of the tree
        WHEN p_id IS NULL THEN 'Root'
        
        -- Rule 2: If its ID never appears as a parent ID anywhere else, it has no children (Leaf)
        -- Note: We filter WHERE p_id IS NOT NULL to protect the NOT IN operator from NULL bugs
        WHEN id NOT IN (SELECT p_id FROM Tree WHERE p_id IS NOT NULL) THEN 'Leaf'
        
        -- Rule 3: Otherwise, it has both a parent and at least one child (Inner branch node)
        ELSE 'Inner'
    END AS type
FROM Tree;