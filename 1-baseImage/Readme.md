1: Best practise of FROM
Construct a small container: https://www.youtube.com/watch?v=wGz_cbtCiEA&t=2s
Try to use Docker official image due to security reason

2: ADD vs COPY in Dockerfile
For most cases, use COPY rather than ADD.
The difference between COPY and ADD is that ADD can uncompress files.
For adding remote file, Please use curl and wget.

3: To run this experiment
  1) start VM `vagrant up`
  2) `vagrant ssh single-machine`
  3) `docker build -t hello .`