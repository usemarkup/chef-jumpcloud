describe file('/etc/jumpcloud_api.conf') do
  its('content') { should eq 'JUMPCLOUD_API_KEY=test-1234' }
end
