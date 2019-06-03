# VerilogQueueCounter
Second term project for Digital Logic Design class, COSE221-01, 2019 Spring Semester, Korea University.

# About Program
logic_design.v file is a Verilog HDL file implementing queue counter.
Input is interpreted as 4, 8, 12 being added to current queue, or 8 being subtracted from current queue.
Reset input is implemented as well.
Queue only counts from 0 to 20, so if 16 people are waiting in current queue, adding 8 people to queue won't change queue's state.
