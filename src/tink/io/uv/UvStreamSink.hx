package tink.io.uv;

import tink.Chunk;
import tink.io.Sink;
import tink.streams.Stream;

using tink.io.PipeResult;
using tink.CoreApi;

class UvStreamSink extends SinkBase<Error, Noise> {
	
	var name:String;
	var wrapper:UvStreamWrapper;
	
	public function new(name, wrapper) {
		this.name = name;
		this.wrapper = wrapper;
	}
	
	override public function consume<EIn>(source:Stream<Chunk, EIn>, options:PipeOptions):Future<PipeResult<EIn, Error, Noise>> {
		var ret = source.forEach(function (chunk:Chunk) {
			return wrapper.write(chunk).map(function(o) return switch o {
				case Success(_): Resume;
				case Failure(e): Clog(e);
			});
		});
			
		if (options.end)
			ret.handle(function (_) wrapper.shutdown().eager());
			
		return ret.map(function (c) return c.toResult(Noise));
	}
}
