--File with utility functions

function TableCount( t )
	local n = 0
	for _ in pairs( t ) do
		n = n + 1
	end
	return n
end

function TableFindKey( table, val )
	if table == nil then
		print( "nil" )
		return nil
	end

	for k, v in pairs( table ) do
		if v == val then
			return k
		end
	end
	return nil
end

function PickRandomValue(t, opt)
    if ( TableCount(t) == 0 ) then
        return nil
    end
    
    if ( opt == nil ) then
		opt = ''
    end
    -- pick a value from the table and return it
    local pick_index = RandomInt( 1, TableCount(t) )
    return t[ opt..pick_index ]
end