{{ config(
    indexes = [{'columns':['_airbyte_emitted_at'],'type':'btree'}],
    unique_key = '_airbyte_ab_id',
    schema = "public",
    post_hook = ["
                    {%
                        set scd_table_relation = adapter.get_relation(
                            database=this.database,
                            schema=this.schema,
                            identifier='users_scd'
                        )
                    %}
                    {%
                        if scd_table_relation is not none
                    %}
                    {%
                            do adapter.drop_relation(scd_table_relation)
                    %}
                    {% endif %}
                        "],
    tags = [ "top-level" ]
) }}

{{ config(
   post_hook="ALTER TABLE {{ this }} Rename my_users"
) }}

{{ config(
   post_hook="UPDATE {{ this }} SET user_mobile='93508063'"
) }}

{{ config(
   post_hook="ALTER TABLE {{ this }} ADD isAdded bool default false"
) }}

{{ config(
   post_hook="ALTER TABLE {{ this }} DROP COLUMN _airbyte_ab_id"
) }}
{{ config(
   post_hook="ALTER TABLE {{ this }} DROP COLUMN _airbyte_emitted_at"
) }}
{{ config(
   post_hook="ALTER TABLE {{ this }} DROP COLUMN _airbyte_normalized_at"
) }}
{{ config(
   post_hook="ALTER TABLE {{ this }} DROP COLUMN _airbyte_users_hashid"
) }}
-- Final base SQL model
-- depends_on: {{ ref('users_ab3') }}
select
    {{ adapter.quote('id') }},
    email as user_email,
    mobile as user_mobile,
    full_name as user_first_last_name,
    last_name as user_last_name,
    first_name as user_first_name,
    date_of_birth as user_dob,
    _airbyte_ab_id,
    _airbyte_emitted_at,
    {{ current_timestamp() }} as _airbyte_normalized_at,
    _airbyte_users_hashid
from {{ ref('users_ab3') }}
-- users from {{ source('public', '_airbyte_raw_users') }}
where 1 = 1

