_ = require "highland"
clone = require "lodash-node/modern/objects/clone"
isEqual = require "lodash-node/modern/objects/isEqual"
isObject = require "lodash-node/modern/objects/isObject"
merge = require "lodash-node/modern/objects/merge"

data = {}

# Deep get on an Object using its path
getDeep = (obj = {}, path) ->
  res = clone obj
  if path
    for key in path.split "."
      return unless res = res[ key ]
  res

# Create a getter function for an object, allowing deep get
getter = (obj) ->
  (path) ->
    getDeep obj, path

# Create a getter function for an object, allowing deep set
setter = (obj = {}) ->
  (path, value) ->
    return unless path
    keys = path.split "."
    lastKey = keys.pop()
    parent = obj
    for key in keys
      parent[ key ] = {} unless isObject parent[ key ]
      parent = parent[ key ]
    parent[ lastKey ] = value

# Read-only current
get = (path) ->
  getDeep data, path

# Start of pipeline: prepare the state for change
prepare = (params = {}) ->
  # Read-write next
  nextData = {}
  set = setter nextData
  next = getter nextData
  # Convenient functions
  added = (key) ->
    value if not get(key)? and value = next key
  changed = (key) ->
    res =
      from: get key
      to: next key
    if isEqual res.from, res.to then false else res
  removed = (key) ->
    value if not next(key)? and value = get key
  reset = (key) ->
    set key, get key

  # State object passed to transforms/commit
  {get, set, next, added, changed, removed, reset, params}

# Apply new state if different from previous one
apply = (nextData) ->
  newData = merge {}, data, nextData, (from, to) ->
    if to? then undefined # default behavior
    else null # set all removals as null to make sure they are applied
  data = newData unless isEqual data, newData

# End of pipeline: apply new state
commit = (state) ->
  apply state.next()

# Process state changes going through the transforms
# If no transforms, directly apply new state
process = (transforms = []) ->
  transforms = [transforms] unless Array.isArray transforms
  transforms.unshift _.map prepare
  transforms.push _.map commit
  transforms.push _.compact # Use compact to filter unchanged states
  pipeline = _.pipeline.apply _, transforms
  (stream) ->
    stream.through pipeline

module.exports = {get, process}
