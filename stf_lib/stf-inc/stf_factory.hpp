#ifndef __STF_FACTORY_HPP__
#define __STF_FACTORY_HPP__

#include <array>
#include <memory>

#include <boost/preprocessor/cat.hpp>
#include <boost/preprocessor/stringize.hpp>

#include "stf_factory_decl.hpp"
#include "stf_ifstream.hpp"
#include "stf_object_id.hpp"

namespace stf {
    /**
     * \class Factory
     *
     * Generic factory class that constructs objects from enums.
     *
     */
    template<typename ObjectType>
    class Factory {
        private:
            using Enum = typename ObjectType::factory_id_type;
            using PoolType = typename ObjectType::pool_type;
            using PtrType = typename PoolType::ConstBaseObjectPointer;

            /**
             * \typedef Constructor
             * type of constructor function used to construct a registered record type
             */
            using Constructor = PtrType(*)(STFIFstream& strm);

            /**
             * \typedef ConstructorArray
             * Array of Constructor handles
             */
            using ConstructorArray = enums::EnumArray<Constructor, Enum>;

            /**
             * Default constructor for unregistered objects. Just throws an exception.
             */
            static inline PtrType defaultConstructor_(STFIFstream&) {
                invalid_descriptor_throw("Attempted to construct unregistered object");
            }

            /**
             * Converts an enum into a value that can be used for array lookups. Can be specialized to handle cases where the enum values used in the STF are different from the ones used internally (e.g. STFRecord)
             * \param object_id ID to convert
             */
            static inline constexpr size_t convertToIndex_(const Enum object_id) {
                return static_cast<size_t>(ObjectIdConverter::fromTrace(object_id));
            }

            /**
             * Gets RecordFactory singleton
             */
            __attribute__((always_inline))
            static inline const Factory& get_() {
                static Factory instance;
                return instance;
            }

            /**
             * Constructs an instance of the record type associated with the given descriptors::encoded::Descriptor
             * \param strm STFIFstream to read data from
             * \param object_id ID of type to construct
             */
            __attribute__((always_inline))
            inline PtrType construct_(STFIFstream& strm, const Enum object_id) const {
                try {
                    const auto& constructor = getConstructor_(object_id);
                    auto ptr = constructor(strm); // cppcheck-suppress danglingTempReference
                    strm.readCallback<typename PoolType::base_type>();
                    return ptr;
                }
                catch(const InvalidDescriptorException&) {
                    invalid_descriptor_throw("Attempted to construct unregistered object: " << object_id);
                }
                catch(const std::out_of_range&) {
                    invalid_descriptor_throw("Attempted to construct invalid object: " << object_id);
                }
            }

            /**
             * Translates an object ID to the constructor for that object
             */
            template<Enum ObjectId, typename dummy_type = void>
            struct constructor_generator {
                static inline constexpr Constructor get();
            };

            template<typename dummy_type>
            struct constructor_generator<Enum::__RESERVED_START, dummy_type> {
                /**
                 * get specialization for __RESERVED_START object ID.
                 * Ensures we always throw an exception if we attempt to construct a __RESERVED_START ID.
                 */
                static inline constexpr Constructor get() {
                    return &defaultConstructor_;
                }
            };

            template<typename dummy_type>
            struct constructor_generator<Enum::__RESERVED_END, dummy_type> {
                /**
                 * get specialization for __RESERVED_END object ID.
                 * Ensures we always throw an exception if we attempt to construct a __RESERVED_END ID.
                 */
                static inline constexpr Constructor get() {
                    return &defaultConstructor_;
                }
            };

            /**
             * Used to initialize the constructors_ array at compile time.
             * Automatically iterates over all object IDs and adds their respective constructor callback functions to the array.
             */
            static inline constexpr ConstructorArray populateConstructorArray_() {
                return enums::populateEnumArray<Constructor, Enum, &defaultConstructor_>(
                    [](auto Index, ConstructorArray constructor_array) {
                        if constexpr(const auto start_idx = convertToIndex_(Index); start_idx < constructor_array.size()) {
                            constructor_array[start_idx] = constructor_generator<Index>::get();
                        }
                        return constructor_array;
                    }
                );
            }

            static inline constexpr ConstructorArray constructors_ = populateConstructorArray_(); /**< Array mapping record descriptors to constructors */

            /**
             * Gets the constructor for the given object ID
             * \param object_id ID of object to construct
             */
            static Constructor getConstructor_(const Enum object_id);

            /**
             * Constructs an instance of the record type associated with the given descriptors::encoded::Descriptor
             * \param strm STFIFstream to read data from
             */
            __attribute__((always_inline))
            inline PtrType construct_(STFIFstream& strm) const {
                Enum object_id;
                strm >> object_id;
                return construct_(strm, object_id);
            }

            Factory() = default;
            Factory(const Factory&) = default;
            ~Factory() = default;

        public:
            /**
             * \typedef ConstructionIdType
             * Enum type used to look up and construct classes from this factory
             */
            using ConstructionIdType = Enum;

            /**
             * Constructs an STFObject from a trace
             * \param strm Stream to extract data from
             */
            __attribute__((always_inline))
            static inline PtrType construct(STFIFstream& strm) {
                return get_().construct_(strm);
            }

            /**
             * Constructs an STFObject from a trace
             * \param strm Stream to extract data from
             * \param object_id Manually-specified ID of class to construct
             */
            __attribute__((always_inline))
            static inline PtrType construct(STFIFstream& strm, const Enum object_id) {
                return get_().construct_(strm, object_id);
            }
    };
} // end namespace stf

/**
 * \def FINALIZE_FACTORY
 *
 * Initializes all of the constructor and deleter functions associated with a particular Factory.
 * Should only be specified ONCE per Factory type in a .cpp file
 */
#define FINALIZE_FACTORY(object_type) \
    template<> \
    object_type::factory_type::Constructor object_type::factory_type::getConstructor_(const object_type::factory_type::ConstructionIdType object_id) { \
        return constructors_[convertToIndex_(object_id)]; \
    } \
    template<> \
    object_type::pool_type::DeleterFuncType object_type::pool_type::getDeleter_(const size_t object_id) { \
        return deleters_[object_id]; \
    }

#define ___TEST_NAMESPACE(test_name, ns, msg) \
    struct test_name;  \
    static_assert(std::is_same_v<test_name, ::ns::test_name>, msg);

#define __TEST_NAMESPACE(name, ns, msg) \
    ___TEST_NAMESPACE(BOOST_PP_CAT(__TEST_NAMESPACE_, name), ns, msg)

#define __PAUSE_NAMESPACE(name, ns) \
    __TEST_NAMESPACE(name, ns, "Not currently in " BOOST_PP_STRINGIZE(ns) " namespace") \
    } \

#define __RESUME_NAMESPACE(ns) \
    namespace ns {

/**
 * \def NAMESPACE_WRAP
 *
 * Ensures that body is instantiated inside the stf namespace
 *
 */
#define NAMESPACE_WRAP(name, ns, body) \
    __PAUSE_NAMESPACE(name, stf::ns) \
    body \
    __RESUME_NAMESPACE(ns)

/**
 * \def REGISTER_WITH_FACTORY
 *
 * Registers an STF object with the factory that will be used to construct it
 *
 */
#define REGISTER_WITH_FACTORY(object_type, cls) \
    __TEST_NAMESPACE(STF, stf, "REGISTER_WITH_FACTORY should only be used in the stf namespace") \
    template<> \
    template<> \
    struct object_type::factory_type::constructor_generator<ObjectIdConverter::toTrace(cls::getTypeId())> { \
        static inline constexpr object_type::factory_type::Constructor get() { \
            return &object_type::pool_type::construct<cls>; \
        } \
    }; \
    template<> \
    template<> \
    struct object_type::pool_type::deleter_generator<cls::getTypeId()> { \
        static inline constexpr object_type::pool_type::DeleterFuncType get() { \
            return &object_type::pool_type::deleter_func_<cls>; \
        } \
    };
#endif
