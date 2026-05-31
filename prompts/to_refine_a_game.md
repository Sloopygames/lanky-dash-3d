
Here are the prompt scripts we want.

First, we want a script that will call Agent A in the following way:

A01 Prompt
Then, A02 Prompt
Loop START
A03 Prompt
A04 Prompt
Loop END: Max 3 loops; exit early if A04 Prompt "3. Do we need to improve?" returns no.


Second, we need a script that will call Agent B and C any time the shared folder updates.
X01 Prompt


To clarify, we will start the process by calling the first script. As Agent A writes JSON objects to the shared folder, the second script should trigger Agent B and Agent C. This will continue until the first script exits the loop.



