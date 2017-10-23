describe package('jcagent') do
  it { should be_installed }
end

describe service('jcagent') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
