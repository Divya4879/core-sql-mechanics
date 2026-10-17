/* =====================================================================================
   LEETCODE 3451: Find Invalid IP Addresses
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Negative Regex Filtering (`NOT REGEXP`), Complex Alternation (`|`), 
      & The IPv4 Regex Standard
      
   2. CORE INSIGHT & CODE MECHANICS:
      Trying to write a Regex that catches every possible invalid variation (e.g., numbers > 255, 
      leading zeros, wrong octet counts) is nearly impossible. 
      The Optimal Strategy: Write a strict Regex that defines a perfectly valid IP, and 
      filter for rows that DO NOT match it.

      Breaking down the "Perfect IPv4 Octet" Regex:
      `(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])`
      
      Because Regex can't do math (< 256), we must define the valid string ranges using OR (`|`):
      - `25[0-5]`      : Matches 250 through 255
      - `2[0-4][0-9]`  : Matches 200 through 249
      - `1[0-9]{2}`    : Matches 100 through 199
      - `[1-9][0-9]`   : Matches 10 through 99 (Prevents leading zeros like '05')
      - `[0-9]`        : Matches 0 through 9 (Allows a single '0', but prevents '00')

      The Full Pipeline:
      - `^` : Start of string.
      - `[OCTET]` : The first number block.
      - `(\\.[OCTET]){3}` : Exactly three repeating blocks of a literal dot followed by an octet.
      - `$` : End of string.

   3. ⚡ THE SQL REGEX CRASH COURSE (YOUR CHEAT SHEET):
      Whenever you face a SQL Regex problem, build your pattern from these core tokens:
      
      ANCHORS (Positioning)
      - `^` : Must start here.
      - `$` : Must end here.
      - `\\b` : Word boundary (clean break like a space or punctuation).

      QUANTIFIERS (Counting)
      - `?` : Zero or one time (Optional).
      - `*` : Zero or more times.
      - `+` : One or more times (Strictly requires at least one).
      - `{n}` : Exactly 'n' times.
      - `{n,m}` : Between 'n' and 'm' times.

      CHARACTER CLASSES (Allowed Values)
      - `[a-z]` : Any lowercase letter.
      - `[A-Za-z0-9]` : Alphanumeric.
      - `[^0-9]` : The `^` inside brackets means NOT. (Matches anything that IS NOT a number).
      
      LOGIC & ESCAPING
      - `(X|Y)` : Match X OR Y.
      - `\\.` : A literal dot. (Without the slashes, a `.` means "any character in existence").

   4. COMMON PITFALLS TO AVOID:
      - Forgetting anchors (`^` and `$`): Without them, the regex engine will find a valid IP 
        hiding inside an invalid string (like "999.192.168.1.1.999").
      - Trying to write an "invalid match" regex instead of just negating a "valid match" regex.
   ===================================================================================== */

WITH invalid_ips AS (
    SELECT 
        ip,
        COUNT(log_id) AS invalid_count
    FROM logs
    -- Define the perfect IP, then negate it
    WHERE ip NOT REGEXP '^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])(\\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])){3}$'
    GROUP BY ip
)
SELECT 
    ip,
    invalid_count
FROM invalid_ips
ORDER BY 
    invalid_count DESC, 
    ip DESC;


/* =====================================================================================
   THE SENIOR ENGINEER CHEAT CODE
   =====================================================================================
   Depending on the exact SQL engine (like standard MySQL 8.0+), you can sometimes bypass 
   Regex entirely for this specific task using built-in networking functions:
   
   WHERE IS_IPV4(ip) = 0
   
   (Note: LeetCode environments often run restricted/older SQL dialects where Regex is 
   the only universally accepted answer, but keep this in your back pocket for production!)
   ===================================================================================== */