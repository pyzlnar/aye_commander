describe AyeCommander::MissingRequiredArgumentError do
  let(:error) { AyeCommander::MissingRequiredArgumentError }

  it 'is an AyeCommander::Error child' do
    expect(error.superclass).to be AyeCommander::Error
  end

  it 'should have a descriptive message of the error' do
    errori = error.new [:taco]
    expect(errori.message).to eq 'Missing required arguments: [:taco]'
  end

  it 'should print the class and message with #inspect' do
    errori   = error.new [:taco]
    expected = '#<AyeCommander::MissingRequiredArgumentError: Missing required arguments: [:taco]>'
    expect(errori.inspect).to eq expected
  end

  it 'should print the message with #to_s' do
    errori = error.new [:taco]
    expect(errori.to_s).to eq 'Missing required arguments: [:taco]'
  end
end

describe AyeCommander::UnexpectedReceivedArgumentError do
  let(:error) { AyeCommander::UnexpectedReceivedArgumentError }

  it 'is an AyeCommander::Error child' do
    expect(error.superclass).to be AyeCommander::Error
  end

  it 'should have a descriptive message of the error' do
    errori = error.new [:taco]
    expect(errori.message).to eq 'Received unexpected arguments: [:taco]'
  end

  it 'should print the class and message with #inspect' do
    errori   = error.new [:taco]
    expected = '#<AyeCommander::UnexpectedReceivedArgumentError: Received unexpected arguments: [:taco]>'
    expect(errori.inspect).to eq expected
  end

  it 'should print the message with #to_s' do
    errori = error.new [:taco]
    expect(errori.to_s).to eq 'Received unexpected arguments: [:taco]'
  end
end
