package com.nativemapper.app.data

import androidx.room.*

@Dao
interface KeyMappingDao {
    @Query("SELECT * FROM key_mappings")
    suspend fun getAll(): List<KeyMapping>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(mapping: KeyMapping)

    @Delete
    suspend fun delete(mapping: KeyMapping)
}
