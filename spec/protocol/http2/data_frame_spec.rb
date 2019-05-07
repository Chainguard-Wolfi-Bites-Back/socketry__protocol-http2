# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'protocol/http2/data_frame'
require_relative 'frame_examples'

RSpec.describe Protocol::HTTP2::DataFrame do
	it_behaves_like Protocol::HTTP2::Frame do
		before do
			subject.pack "Hello World!"
		end
	end
	
	context 'wire representation' do
		let(:stream) {StringIO.new}
		
		let(:payload) {'Hello World!'}
		
		let(:data) do
			[0, 12, 0x0, 0x1, 0x1].pack('CnCCNC*') + payload
		end
		
		it "should write frame to buffer" do
			subject.set_flags(Protocol::HTTP2::END_STREAM)
			subject.stream_id = 1
			subject.payload = payload
			subject.length = payload.bytesize
			
			subject.write(stream)
			
			expect(stream.string).to be == data
		end
		
		it "should read frame from buffer" do
			stream.write(data)
			stream.seek(0)
			
			subject.read(stream)
			
			expect(subject.length).to be == payload.bytesize
			expect(subject.flags).to be == Protocol::HTTP2::END_STREAM
			expect(subject.stream_id).to be == 1
			expect(subject.payload).to be == payload
		end
	end
	
	describe '#pack' do
		it "adds appropriate padding" do
			subject.pack "Hello World!", padding_size: 4
			
			expect(subject.length).to be == 16
			expect(subject.payload[0].ord).to be == 4
		end
	end
	
	describe '#unpack' do
		it "removes padding" do
			subject.pack "Hello World!"
			
			expect(subject.unpack).to be == "Hello World!"
		end
	end
end
