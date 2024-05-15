create extension if not exists pgcrypto;


create or replace function gen_ulid()
	returns text -- A randomly generated ULID String
as
$$
declare
    -- Crockford's Base32
	encoding  bytea = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
	timestamp bytea = E'\\000\\000\\000\\000\\000\\000';
	output    text  = '';
	unix_time bigint;
	ulid      bytea;
begin
	unix_time = (extract(epoch from clock_timestamp()) * 1000)::bigint;
	timestamp = set_byte(timestamp, 0, (unix_time >> 40)::bit(8)::integer);
	timestamp = set_byte(timestamp, 1, (unix_time >> 32)::bit(8)::integer);
	timestamp = set_byte(timestamp, 2, (unix_time >> 24)::bit(8)::integer);
	timestamp = set_byte(timestamp, 3, (unix_time >> 16)::bit(8)::integer);
	timestamp = set_byte(timestamp, 4, (unix_time >> 8)::bit(8)::integer);
	timestamp = set_byte(timestamp, 5, unix_time::bit(8)::integer);

	-- 10 entropy bytes
	ulid = timestamp || gen_random_bytes(10);

	-- Encode the timestamp
	output = output || chr(get_byte(encoding, (get_byte(ulid, 0) & 224) >> 5));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 0) & 31)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 1) & 248) >> 3));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 1) & 7) << 2) | ((get_byte(ulid, 2) & 192) >> 6)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 2) & 62) >> 1));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 2) & 1) << 4) | ((get_byte(ulid, 3) & 240) >> 4)));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 3) & 15) << 1) | ((get_byte(ulid, 4) & 128) >> 7)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 4) & 124) >> 2));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 4) & 3) << 3) | ((get_byte(ulid, 5) & 224) >> 5)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 5) & 31)));

  -- Encode the entropy
	output = output || chr(get_byte(encoding, (get_byte(ulid, 6) & 248) >> 3));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 6) & 7) << 2) | ((get_byte(ulid, 7) & 192) >> 6)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 7) & 62) >> 1));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 7) & 1) << 4) | ((get_byte(ulid, 8) & 240) >> 4)));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 8) & 15) << 1) | ((get_byte(ulid, 9) & 128) >> 7)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 9) & 124) >> 2));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 9) & 3) << 3) | ((get_byte(ulid, 10) & 224) >> 5)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 10) & 31)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 11) & 248) >> 3));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 11) & 7) << 2) | ((get_byte(ulid, 12) & 192) >> 6)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 12) & 62) >> 1));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 12) & 1) << 4) | ((get_byte(ulid, 13) & 240) >> 4)));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 13) & 15) << 1) | ((get_byte(ulid, 14) & 128) >> 7)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 14) & 124) >> 2));
	output = output || chr(get_byte(encoding, ((get_byte(ulid, 14) & 3) << 3) | ((get_byte(ulid, 15) & 224) >> 5)));
	output = output || chr(get_byte(encoding, (get_byte(ulid, 15) & 31)));

	return output;
end
$$
	language plpgsql
    volatile;


create or replace function check_ulid(
	id text
)
returns boolean
as $$
begin
	if id ~ '^[0-9A-Z]{26}$' then
  	return true;
	else
  	return false;
	end if;
end
$$
	language plpgsql
    volatile;


create or replace function gen_typeid(
	prefix text
)
returns text
as $$
begin
	if (prefix is null) or (length(prefix) = 0) or not (prefix ~ '^[a-z]+(_[a-z]+)*$') then
    raise exception 'typeid prefix must not be null or empty, must start with a lowercase letter, consist of lowercase letters and underscores, and cannot start with an underscore or end with an underscore';
  end if;
 
	return (prefix || '_' || gen_ulid());
end
$$
	language plpgsql
	volatile;
    
    
create or replace function check_typeid(
	id text,
  prefix text
)
returns boolean
as $$
begin
	if id ~ ('^' || prefix || '_[0-9A-Z]{26}$') then
  	return true;
	else
  	return false;
	end if;
end
$$
	language plpgsql
    volatile;