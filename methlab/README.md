Test directory (I call all test directories `methlab`)

Here I'm gonna put various attempts at understanding and implementing parallel parsers, mostly in BQN because I find that to be a very good language to experiment with this sort of thing.  
Although please note that CBQN, the reference impelementation for the BQN programming language, and the one I'm using for these tests, doesn't do GPU, but only CPU side SIMD; and these experimentations are aimed at making GPU parsers later down the line.

But yeah, OpenCL is painful; Cuda can suck my dick; Futhark is nice, but unwieldy; BQN just works... I'm gonna use BQN.
