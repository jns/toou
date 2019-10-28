json.array! @groups do |group|
    json.name group.name
    json.id group.id
    json.passes group.valid_pass_quantities do |buyable, passes|
        json.buyable_id buyable.id
        json.buyable_name buyable.name
        json.buyable_type buyable.class.name
        json.pass_count passes.count
    end
end