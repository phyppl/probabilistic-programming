// Based on bi/sample.bi in Birch.Standard
program sampler(
    input:String?,
    output:String?,
    config:String?,
    model:String?,
    nsamples:Integer?,
    seed:Integer?,
    quiet:Boolean <- false) {
  /* config */
  configBuffer:MemoryBuffer;
  if config? {
    reader:Reader <- Reader(config!);
    reader.read(configBuffer);    
    reader.close();
  }

  /* random number generator */
  if seed? {
    global.seed(seed!);
  } else if config? {
    auto buffer <- configBuffer.getInteger("seed");
    if buffer? {
      global.seed(buffer!);
    }
  } else {
    global.seed();
  }

  /* model */
  auto buffer <- configBuffer.getObject("model");
  if !buffer? {
    buffer <- configBuffer.setObject("model");
  }
  if !buffer!.getString("class")? && model? {
    buffer!.setString("class", model!);
  }
  auto m <- Model?(make(buffer));
  if !m? {
    error("could not create model; the model class should be given as " + 
        "model.class in the config file, and should derive from Model.");
  }

  /* filter */
  buffer <- configBuffer.getObject("filter");
  if !buffer? {
    buffer <- configBuffer.setObject("filter");
  }
  if !buffer!.getString("class")? {
    buffer!.setString("class", "AliveParticleFilter");
  }
  auto filter <- ParticleFilter?(make(buffer));
  if !filter? {
    error("could not create filter; the filter class should be given as " + 
        "filter.class in the config file, and should derive from ParticleFilter.");
  }

  /* sampler */
  buffer <- configBuffer.getObject("sampler");
  if !buffer? {
    buffer <- configBuffer.setObject("sampler");
  }
  if !buffer!.getString("class")? {
    buffer!.setString("class", "PhySampler");
  }
  auto sampler <- PhySampler?(make(buffer));
  if !sampler? {
    error("could not create sampler; the sampler class should be given as " + 
        "sampler.class in the config file, and should derive from ParticleSampler.");
  }
  sampler!.filter <- filter!;
  if nsamples? {
    sampler!.nsamples <- nsamples!;
  }

  /* input */
  auto inputPath <- input;
  if !inputPath? {
    inputPath <-? configBuffer.getString("input");
  }
  if inputPath? {
    reader:Reader <- Reader(inputPath!);
    inputBuffer:MemoryBuffer;
    reader.read(inputBuffer);
    reader.close();
    inputBuffer.get(m!);
  }

  /* output */
  outputWriter:Writer?;
  outputPath:String? <- output;
  if !outputPath? {
    outputPath <-? configBuffer.getString("output");
  }
  if outputPath? {
    outputWriter <- Writer(outputPath!);
    outputWriter!.startSequence();
  }

  /* progress bar */
  bar:ProgressBar;
  if !quiet {
    bar.update(0.0);
  }

  /* sample */
  auto f <- sampler!.sample(m!);
  auto n <- 0;
  tic();
  while f? {
    sample:Model[_];
    lweight:Real[_];
    lnormalize:Real[_];
    ess:Real[_];
    npropagations:Integer[_];
    (sample, lweight, lnormalize, ess, npropagations) <- f!;
    if outputWriter? {
      buffer:MemoryBuffer;
      buffer.set("sample", sample);
      buffer.set("lweight", lweight);
      buffer.set("lnormalize", lnormalize);
      buffer.set("ess", ess);
      buffer.set("npropagations", npropagations);
      buffer.set("time", toc());
      outputWriter!.write(buffer);
      outputWriter!.flush();
    }

    n <- n + 1;
    if !quiet {
      bar.update(Real(n)/sampler!.nsamples);
    }
    tic();
  }

  /* finalize output */
  if outputWriter? {
    outputWriter!.endSequence();
    outputWriter!.close();
  }
}
