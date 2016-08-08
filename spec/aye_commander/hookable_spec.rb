describe AyeCommander::Hookable::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  %i(before around after).each do |kind|
    context ".#{kind}" do
      it "adds the args to the #{kind} hooks array" do
        command.send kind, :some, :method
        expect(command.before_hooks).to eq [:some, :method]
      end

      it 'adds the received block as a block, after the args' do
        command.send(kind, :some) { :hello }
        expect(command.send("#{kind}_hooks").count).to eq 2
        expect(command.send("#{kind}_hooks").last).to be_instance_of Proc
      end

      it 'adds the args at the end of the array' do
        command.send kind, :first
        command.send kind, :second, :third
        expect(command.send "#{kind}_hooks").to eq [:first, :second, :third]
      end

      it 'adds the args at the beginning of the array with the prepend option' do
        command.send kind, :first
        command.send kind, :second, :third, prepend: true
        expect(command.send "#{kind}_hooks").to eq [:second, :third, :first]
      end
    end

    context ".#{kind}_hooks" do
      it 'returns empty array with nothing set' do
        expect(command.send "#{kind}_hooks").to eq []
      end

      it 'returns the array of hooks' do
        command.instance_variable_set :@hooks, kind => [:hello]
        expect(command.send "#{kind}_hooks").to eq [:hello]
      end
    end
  end

  %i(before after).each do |kind|
    context ".call_#{kind}_hooks" do
      before :each do
        body = -> { success? }
        command.send :define_method, :by_symbol, &body
        command.send :define_method, :by_method, &body
        command.send kind, :by_symbol, instance.method(:by_method), body, &body
      end

      it 'makes all supported hooks callable' do
        expect(command.send "call_#{kind}_hooks", instance).to all(respond_to :call)
      end

      it 'calls all the prepared hooks' do
        hooks = command.send "call_#{kind}_hooks", instance
        allow(command).to receive(:prepare_hooks).and_return(hooks)
        expect(hooks).to all(receive :call)
        command.send "call_#{kind}_hooks", instance
      end

      it 'runs all the prepared hooks in the instance context' do
        expect(instance).to receive(:success?).exactly(4).times
        command.send "call_#{kind}_hooks", instance
      end
    end
  end

  context '.call_around_hooks' do
    before :each do
      body = lambda do |step|
        @order ||=[]
        number = order.count + 1
        @order << number

        success?
        step.call
        failure?

        @order << number
      end

      command.send :define_method, :by_symbol, &body
      command.send :define_method, :by_method, &body
      command.around :by_symbol, instance.method(:by_method), body, &body
    end

    it 'compacts everything into one proc' do
      expect(command.call_around_hooks(instance).count).to eq 1
    end

    it 'calls everything' do
      expect(instance).to receive(:success?).exactly(4).times
      expect(instance).to receive(:failure?).exactly(4).times
      command.call_around_hooks(instance)
    end

    it 'should call the hooks in the correct order' do
      command.call_around_hooks(instance)
      expect(instance.order).to eq [1,2,3,4,4,3,2,1]
    end
  end
end
