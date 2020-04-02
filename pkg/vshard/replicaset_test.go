package vshard

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestReplicaSet_Followers(t *testing.T) {
	type fields struct {
		UUID       ReplicaSetUUID
		MasterUUID InstanceUUID
		Instances  []Instance
	}

	tests := []struct {
		name   string
		fields fields
		want   []InstanceUUID
	}{
		{
			name: "NoFollowers",
			fields: fields{
				UUID:       "uuid_1",
				MasterUUID: "master_uuid_1",
				Instances:  []Instance{},
			},
			want: []InstanceUUID{},
		},
		{
			name: "MultipleFollowers_UseStorageInfo",
			fields: fields{
				UUID:       "uuid_1",
				MasterUUID: "master_uuid_1",
				Instances: []Instance{
					{
						UUID: "master_uuid_1",
						StorageInfo: StorageInfo{
							Replication: Replication{
								Status: StatusMaster,
							},
						},
					},
					{
						UUID: "replica_uuid_1",
						StorageInfo: StorageInfo{
							Replication: Replication{
								Status: StatusFollow,
							},
						},
					},
					{
						UUID: "replica_uuid_2",
						StorageInfo: StorageInfo{
							Replication: Replication{
								Status: StatusFollow,
							},
						},
					},
				},
			},
			want: []InstanceUUID{"replica_uuid_1", "replica_uuid_2"},
		},
	}

	for _, tv := range tests {
		tt := tv
		t.Run(tt.name, func(t *testing.T) {
			set := &ReplicaSet{
				UUID:       tt.fields.UUID,
				MasterUUID: tt.fields.MasterUUID,
				Instances:  tt.fields.Instances,
			}

			followers := set.Followers()
			got := make([]InstanceUUID, 0, len(followers))
			for _, f := range followers {
				got = append(got, f.UUID)
			}

			assert.Equal(t, tt.want, got)
		})
	}
}