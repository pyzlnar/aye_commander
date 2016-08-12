describe AyeCommander::MissingRequiredArgumentError do
  let(:error) { AyeCommander::MissingRequiredArgumentError }

  it 'is an AyeCommander::Error child' do
    expect(error.superclass).to be AyeCommander::Error
  end

  it 'should have a descriptive message of the error' do
    errori = error.new [:taco]
    expect(errori.message).to eq 'Missing required arguments: [:taco]'
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
end
