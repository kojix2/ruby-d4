module D4
  module FFI
    extend ::FFI::Library

    begin
      ffi_lib D4.lib_path
    rescue LoadError => e
      raise LoadError, "#{e}\nCould not find #{D4.lib_path}"
    end

    # @!macro attach_function
    #   @!scope class
    #   @!method $1(${2--2})
    #   @return [${-1}] the return value of $0
    def self.attach_function(*)
      super
    rescue ::FFI::NotFoundError => e
      warn e.message # if $VERBOSE
    end

    def self.attach_variable(*)
      super
    rescue ::FFI::NotFoundError => e
      warn e.message # if $VERBOSE
    end

    # The handle for a D4 file
    typedef :pointer, :d4_file_t

    # Describes what kind of dictionary this d4 file holds
    # - The dictionary that is defined by a range of values
    # - The dictionary describes by a value map
    enum :d4_dict_type_t, [
      :D4_DICT_SIMPLE_RANGE, 0,
      :D4_DICT_VALUE_MAP, 1
    ]

    # The dictionary data for simple ranage dictionary
    class D4SimpleRangeDictT < ::FFI::Struct
      layout \
        :low, :int32_t,
        :high, :int32_t
    end

    # The dictionary data or value map dictionary
    class D4ValueMapDictT < ::FFI::Struct
      layout \
        :size, :size_t,
        :values, :pointer
    end

    class DictData < ::FFI::Union
      layout \
        :simple_range, D4SimpleRangeDictT,
        :value_map, D4ValueMapDictT
    end

    # The metadata of a D4 file
    class D4FileMetadataT < ::FFI::Struct
      layout \
        :chrom_count, :size_t,       # Number of chromosomes defined in the file
        :chrom_names, :pointer,      # List of chromosome names
        :chrom_size, :pointer,       # List o fchromosome sizes
        :dict_type, :d4_dict_type_t, # Dictionary type
        :denominator, :double,       # Denominator, set to 1.0 unless the file represents a real-number D4
        :dict_data, DictData         # Dictionary data
    end

    # A value interval
    class D4IntervalT < ::FFI::Struct
      layout \
        :left, :int32_t,
        :right, :int32_t,
        :value, :int32_t
    end

    # Open a D4 file, mode can be either "r" or "w"
    attach_function 'd4_open', [
      :string, # path
      :string # mode
    ], :d4_file_t

    # Close a opened D4 file
    attach_function 'd4_close', [
      :d4_file_t
    ], :int

    # Load the metadata defined in the opened D4 file
    attach_function 'd4_file_load_metadata', [
      :d4_file_t,
      D4FileMetadataT.ptr
    ], :int

    # Update the metadata defined in the opened D4 file.
    # Note: this requires the D4 file is opened in write mode.
    attach_function 'd4_file_update_metadata', [
      :d4_file_t,
      :pointer # d4_file_metadata_t
    ], :int

    # Cleanup the memory that is allocated to hold the metadata.
    # Note this doesn't free the metadata object itself.
    # attach_function 'd4_file_metadata_clear', [
    #   :pointer
    # ], :void

    attach_function 'd4_file_read_values', [
      :d4_file_t,
      :pointer, # int32_t* buf
      :size_t # size_t count
    ], :ssize_t

    # Read the values from a D4 file from the current cursor location
    attach_function 'd4_file_read_intervals', [
      :d4_file_t,
      D4IntervalT.ptr,
      :size_t # size_t count
    ], :ssize_t

    # Write the values to D4 file
    attach_function 'd4_file_write_values', [
      :d4_file_t,
      :pointer, # int32_t* buf
      :size_t # size_t count
    ], :ssize_t

    # Write intervals to D4 file
    attach_function 'd4_file_write_intervals', [
      :d4_file_t,
      D4IntervalT.ptr,
      :size_t
    ], :ssize_t

    # Returns the cursor location of the opened D4 file
    attach_function 'd4_file_tell', [
      :d4_file_t,
      :string, # chr* name_buf
      :size_t, # size_t buf_size
      :pointer # uint32_t* pos_buf
    ], :int

    # Perform random access in a opended D4 file
    attach_function 'd4_file_seek', [
      :d4_file_t,
      :string, # chr* chrom
      :uint32_t # pos
    ], :int

    # Index accessing APIs
    enum :d4_index_kind_t, [
      :D4_INDEX_KIND_SUM, 0
    ]

    class D4IndexResultT < ::FFI::Union
      layout \
        :sum, :double
    end

    attach_function 'd4_index_check', %i[
      d4_file_t
      d4_index_kind_t
    ], :int

    attach_function 'd4_index_query', [
      :d4_file_t,
      :d4_index_kind_t,
      :string, # chr* chrom
      :uint32_t, # start
      :uint32_t, # end
      D4IndexResultT.ptr # buf
    ], :int

    typedef :pointer, :d4_task_part_t

    # Already defined? D4TaskPartT

    # D4TaskPartT = D4TaskPartT

    # What type of task we want to perfome
    enum :d4_task_mode_t, [
      :D4_TASK_READ, 0,
      :D4_TASK_WRITE, 1
    ]

    # The result of a task partition has been executed
    class D4TaskPartResultT < ::FFI::Struct
      layout \
        :task_context, :pointer, # The user defined task context pointer
        :status, :int            # The completion status of this task partition
    end

    # The actual data structure that used to define a task
    class D4TaskDeskT < ::FFI::Struct
      layout \
        :mode, :d4_task_mode_t,            # What is the mode of the task
        :part_size_limit, :uint32_t,       # What is the maximum size of each task partition in base pairs
        :num_cpus, :uint32_t,              # The desired number of CPUs we want to use for this task, set to 0 if we want the library to choose automatically
        :part_context_create_cb, :pointer, # The callback function that is used to create the partition context, which will be propogate to the task_result data structure
        :part_process_cb, :pointer,        # The actual task partition processing code
        :part_finalize_cb, :pointer,       # The final cleanup step of a task
        :extra_data, :pointer              # The extra data we want to pass to all the callback functions
    end

    # Run a task, the task is described by the task description struct
    attach_function 'd4_file_run_task', [
      :d4_file_t,
      D4TaskDeskT.ptr
    ], :int

    # Read values from task part. Note this should be used in a processing callback function
    attach_function 'd4_task_read_values', [
      :d4_task_part_t,
      :uint32_t, # offset
      :pointer,  # int32_t* buf
      :size_t    # count
    ], :ssize_t

    # Write values from task part. Note this should be used in a processing callback function
    attach_function 'd4_task_write_values', [
      :d4_task_part_t,
      :uint32_t, # offset
      :pointer,  # int32_t* buf
      :size_t    # count
    ], :ssize_t

    # Read intervals from task part. Note this should be used in a processing callback function
    attach_function 'd4_task_read_intervals', [
      :d4_task_part_t,
      D4IntervalT.ptr, # data
      :size_t
    ], :ssize_t

    # Get the chromosome name this task part is working on. Note this should be used in a processing callback function
    attach_function 'd4_task_chrom', %i[
      d4_task_part_t
      string
      size_t
    ], :int

    # Get the locus name this task part is working on. Note this should be used in a processing callback functionGet the locus name this task part is working on. Note this should be used in a processing callback function
    attach_function 'd4_task_range', %i[
      d4_task_part_t
      pointer
      pointer
    ], :int

    # Read values from task part. Note this should be used in a processing callback function
    attach_function 'd4_file_profile_depth_from_bam', [
      :string, # bam_path
      :string, # d4_path
      D4FileMetadataT.ptr # header
    ], :int

    # Clear the latest D4 library error
    attach_function 'd4_error_clear', [], :void

    # Read the latest human-readable error message
    attach_function 'd4_error_message', [
      :pointer, # char* buf
      :size_t   # size_t buf_size
    ], :string

    # Get the latest error number
    attach_function 'd4_error_num', [], :int
  end
end
