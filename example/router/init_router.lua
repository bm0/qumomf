vshard = require('vshard')

local cfg = {
    memtx_memory = 100 * 1024 * 1024,
    bucket_count = 120,
    rebalancer_disbalance_threshold = 10,
    rebalancer_max_receiving = 1000,

    sharding = {
        ['7432f072-c00b-4498-b1a6-6d9547a8a150'] = { -- replicaset #1
            replicas = {
                ['a94e7310-13f0-4690-b136-169599e87ba0'] = {
                    uri = 'qumomf:qumomf@qumomf_1_m.ddk:3301',
                    name = 'qumomf_1_m',
                    master = true
                },
                ['bd1095d1-1e73-4ceb-8e2f-6ebdc7838cb1'] = {
                    uri = 'qumomf:qumomf@qumomf_1_s.ddk:3301',
                    name = 'qumomf_1_s'
                }
            },
        }, -- replicaset #1
        ['5065fb5f-5f40-498e-af79-43887ba3d1ec'] = { -- replicaset #2
            replicas = {
                ['a3ef657e-eb9a-4730-b420-7ea78d52797d'] = {
                    uri = 'qumomf:qumomf@qumomf_2_m.ddk:3301',
                    name = 'qumomf_2_m',
                    master = true
                },
                ['bd64dd00-161e-4c99-8b3c-d3c4635e18d2'] = {
                    uri = 'qumomf:qumomf@qumomf_2_s_1.ddk:3301',
                    name = 'qumomf_2_s_1'
                },
                ['cc4cfb9c-11d8-4810-84d2-66cfbebb0f6e'] = {
                    uri = 'qumomf:qumomf@qumomf_2_s_2.ddk:3301',
                    name = 'qumomf_2_s_2'
                }
            },
        }, -- replicaset #2
    }, -- sharding
}

cfg.listen = 3301
vshard.router.cfg(cfg)

box.once("init", function()
    box.schema.user.create('qumomf', { password = 'qumomf', if_not_exists = true })
    box.schema.user.grant('qumomf', 'read,write,create,execute', 'universe')
end)

vshard.router.bootstrap()
vshard.router.discovery_wakeup()

dofile('/etc/tarantool/instances.enabled/qumomf/router/router.lua')

