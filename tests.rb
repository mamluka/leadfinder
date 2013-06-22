require 'tire'


Tire.index 'leads_test' do
  delete
  create settings: {
      number_of_shards: 1,
      number_of_replicas: 0,
      refresh_interval: -1,
      'translog.flush_threshold_ops' => 50000,
      'translog.flush_threshold_size' => '2000mb',
      'translog.flush_threshold_period' => '210m',
      'merge.policy.max_merge_at_once' => 2,
      'merge.policy.max_merged_segment' => '2g',
  }
end

Tire::Configuration.client.put Tire.index('leads_test').url+'/household/_mapping',
                               { :household=> { :properties => { :people => { :type => 'nested' } } } }.to_json


Tire.index 'leads_test' do
  import [
             {people: [{age: 30}, {age: 30}, {age: 10}, {age: 15}], phone: '1',_type:'household'},
             {people: [{age: 301}, {age: 310}, {age: 10}, {age: 15}], phone: '2',_type:'household'},
             {people: [{age: 302}, {age: 330}, {age: 10}, {age: 15}], phone: '3',_type:'household'},
             {people: [{age: 302}, {age: 30}, {age: 10}, {age: 15}], phone: '4',_type:'household'},
         ]
  refresh
end
