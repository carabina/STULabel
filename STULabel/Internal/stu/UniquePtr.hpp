// Copyright 2018 Stephan Tolksdorf

#pragma once

#include "stu/TypeTraits.hpp"

namespace stu {

template <typename T, void (* deleter)(T*) noexcept = nullptr>
class UniquePtr {
  T* pointer_{};

  STU_INLINE
  void destroy() const {
    if (pointer_) {
      if constexpr (deleter != nullptr) {
        deleter(pointer_);
      } else {
        delete pointer_;
      }
    }
  }

public:
  STU_INLINE_T
  UniquePtr() = default;

  /* implicit */ STU_INLINE_T
  UniquePtr(std::nullptr_t) noexcept {}

  explicit STU_INLINE_T
  UniquePtr(T* pointer) noexcept
  : pointer_(pointer)
  {}

  UniquePtr(const UniquePtr&) = delete;
  UniquePtr& operator=(const UniquePtr&) = delete;

  STU_INLINE_T
  UniquePtr(UniquePtr&& other) noexcept
  : pointer_(std::exchange(other.pointer_, nullptr))
  {}

  template <typename U,
            EnableIf<isConvertible<U*, T*>> = 0>
  STU_INLINE_T
  UniquePtr(UniquePtr<U>&& other) noexcept
  : pointer_(std::exchange(other.pointer_, nullptr))
  {}

  STU_INLINE
  UniquePtr& operator=(std::nullptr_t) noexcept {
    destroy();
    pointer_ = nullptr;
    return *this;
  }

  STU_INLINE
  UniquePtr& operator=(UniquePtr&& other) noexcept {
    return this->template operator=<T>(std::move(other));
  }

  template <typename U,
            EnableIf<isConvertible<U*, T*>> = 0>
  STU_INLINE
  UniquePtr& operator=(UniquePtr<U>&& other) noexcept {
    *this = nullptr;
    pointer_ = std::exchange(other.pointer_, nullptr);
    return *this;
  }

  STU_INLINE
  ~UniquePtr() {
    destroy();
  }

  STU_INLINE_T
  explicit operator bool() const noexcept { return pointer_ != nullptr; }

  [[nodiscard]] STU_INLINE_T
  T* toRawPointer() && noexcept {
    T* const pointer = pointer_;
    pointer_ = nullptr;
    return pointer;
  }

  STU_INLINE_T
  T& operator*() const { return *pointer_; }

  STU_INLINE_T
  T* operator->() const { return pointer_; }

  STU_INLINE_T
  T* get() const { return pointer_; }

  STU_CONSTEXPR_T
  friend bool operator==(const UniquePtr& lhs, std::nullptr_t) noexcept { return  !lhs; }
  STU_CONSTEXPR_T
  friend bool operator!=(const UniquePtr& lhs, std::nullptr_t) noexcept { return !!lhs; }

  STU_CONSTEXPR_T
  friend bool operator==(std::nullptr_t, const UniquePtr& rhs) noexcept { return  !rhs; }
  STU_CONSTEXPR_T
  friend bool operator!=(std::nullptr_t, const UniquePtr& rhs) noexcept { return !!rhs; }
};

template <typename T>
UniquePtr(T*) -> UniquePtr<T>;

template <typename T>
struct IsBitwiseMovable<UniquePtr<T>> : True {};

} // namespace stu